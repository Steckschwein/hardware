text_mode_40 	= 1
num_ls_entries 	= $03

.zeropage
tmp0:	.byte $00
tmp1:	.byte $00
tmp5:	.byte $00

.segment "OS"
.include "kernel.inc"
.include "kernel_jumptable.inc"
.include "fat32.inc"

dir_attrib_mask		= $0319
steckos_start 		= $1000
KEY_RETURN 			= $0d
KEY_BACKSPACE 		= $08
KEY_ESCAPE			= $1b
KEY_ESCAPE_CRSR_UP	= 'A'
KEY_ESCAPE_CRSR_DOWN	= 'B'
BUF_SIZE			= 32

retvec = $01
entries = $00

cmdptr				= $d6
paramptr			= $d8
buf 				= $e800 ; Input buffer 80 bytes. end: $d800
endbuf				= buf + BUF_SIZE*16
bufptr				= $d0
bufhwm				= $d2
; Address pointers for serial upload
startaddr	= $d9
entryvec			= $d4


;---------------------------------------------------------------------------------------------------------
; init shell
;  - init sd card (again)
;  - mount sd card
;  - print welcome message
;---------------------------------------------------------------------------------------------------------

init:
	; jsr init_textui
	
	sei
	jsr krn_init_sdcard
	cli
	lda errno
	beq @l1

	printstring "SD card init error"

	jmp hello

@l1:
	jsr krn_mount
	lda errno
	beq @l2

	printstring "SD card mount error"
	jmp hello

@l2: 

	SetVector mainloop, retvec
	SetVector buf, bufptr

	; set attrib mask. hide volume label and hidden files
	lda #$0a
	sta dir_attrib_mask

	jmp	hello

mainloop:
	; output prompt character
	
	crlf
	lda #'>'
	jsr krn_chrout
	
	; reset input buffer
	lda #$00
	tay
	sta (bufptr)

	; put input into buffer until return is pressed
inputloop:	
	jsr krn_keyin

	cmp #KEY_RETURN ; return?
	beq parse

	cmp #KEY_BACKSPACE
	beq backspace

	cmp #KEY_ESCAPE
	beq escape


	sta (bufptr),y
	iny

line_end:
	jsr terminate
	jsr krn_chrout

	; prevent overflow of input buffer 
	cpy #BUF_SIZE
	beq mainloop

	
	bra inputloop

backspace:
		cpy #$00
		beq inputloop

		dey

		bra line_end

escape:
		jsr krn_getkey
; 		cmp #KEY_ESCAPE_CRSR_UP
; 		bne +

; 	jsr .decbufptr
; 	bra ++

; +	cmp #KEY_ESCAPE_CRSR_DOWN
; 	bne +

; 	jsr .incbufptr
; ++
		jsr printbuf

; +	
		bra inputloop

terminate:
		pha
		lda #$00
		sta (bufptr),y
		pla
		rts

parse:
		copypointer bufptr, cmdptr

		; find begin of command word
foo:	lda (cmdptr)	; skip non alphanumeric stuff	
		bne @l2
		jmp mainloop
@l2:
		cmp #$20
		bne @l3
		inc cmdptr
		bra foo
@l3:
		copypointer cmdptr, paramptr

	; find begin of parameter (everything behind the command word, separated by space)
	; first, fast forward until space or abort if null (no parameters then)
@l4:	lda (paramptr)
		beq @l7
		cmp #$20
		beq @l5
		inc paramptr
		bra @l4	
@l5:
	; space found.. fast forward until non space or null
@l6:	lda (paramptr)
		beq @l7
		cmp #$20
		bne @l7
		inc paramptr
		bra @l6
@l7:

		SetVector buf, bufptr

		jsr terminate
	

compare:
		; compare 	
		ldx #$00
@l1:	ldy #$00
@l2:	lda (cmdptr),y

		; if not, there is a terminating null
		; cmp #$00
		bne @l3

		cmp cmdlist,x
		beq cmdfound

		; command string in buffer is terminated with $20 if there are cmd line arguments
	
@l3:
		cmp #$20
		bne @l4

		cmp cmdlist,x
		bne cmdfound

@l4:
		; make lowercase
		ora #$20

		cmp cmdlist,x
		bne @l5	; difference. this isnt the command were looking for

		iny
		inx

		bra @l2

		; next cmdlist entry
@l5:
		inx
		lda cmdlist,x
		bne @l5
		inx
		inx
		inx

		lda cmdlist,x
		cmp #$ff
		beq unknown
		bra @l1

cmdfound:
		inx

		jmp (cmdlist,x) ; 65c02 FTW!!	

unknown:
		lda (bufptr)
		beq @l1

		; +SetVector .buf, paramptr
		; +ShellPrintString .crlf
		crlf
		jmp run

@l1:	jmp mainloop

printbuf:
		ldy #$01
		sty crs_x
		jsr krn_textui_update_crs_ptr
		
		ldy #$00
@l1:	lda (bufptr),y
		beq @l2
		sta buf,y
		jsr krn_chrout
		iny
		bra @l1
@l2:	rts


cmdlist:
	.byte "dir"
	.byte $00
	.word dir

	.byte "ll"
	.byte $00
	.word dir

	.byte "ls"
	.byte $00
	.word ls

	.byte "cd"
	.byte $00	
	.word cd
	
	; !text "upload"
	; !byte $00	
	; !word .upload

	; !text "init"
	; !byte $00	
	; !word .init

	.byte "help"
	.byte $00	
	.word help

	.byte "dump"
	.byte $00	
	.word dump
	
	; End of list
	.byte $ff



atoi:
		cmp #'9'+1
		bcc @l1 	; 0-9?
		; must be hex digit
		adc #$08
		and #$0f
		rts

@l1:	sec
		sbc #$30
		rts

param2fileptr:
 	copypointer paramptr, filenameptr
 	rts


dir_show_entry_short:
		pha
		jsr print_filename
		lda #' '
		jsr krn_chrout
		lda #' '
		jsr krn_chrout

		dec entries
		bne @l1	
		crlf
		lda #num_ls_entries
		sta entries
@l1:
		pla
		rts

dir_show_entry:
		pha
		jsr print_filename
	
		lda #' '
		jsr krn_chrout

		ldy #DIR_Attr
		lda (dirptr),y


		ror
		ror
		ror
		bcc @l1
		lda #'V'
		bra @l4
@l1:
		ror
		bcc @l2
		lda #'S'
		bra @l4
@l2:
		ror
		bcc @l3
		lda #'D'
		bra @l4
@l3:
		lda #'F'	
@l4:
		jsr krn_chrout
		lda #' '
		jsr krn_chrout
		
		ldy #DIR_FileSize + 1 +1
@l5:	dey
		lda (dirptr),y
		jsr krn_hexout

		cpy #DIR_FileSize
		bne @l5

		lda #' '
		jsr krn_chrout

		ldy #DIR_WrtDate 
		lda (dirptr),y
		and #%00011111
		jsr decoutz
	
		; month
		iny
		lda (dirptr),y
		lsr
		tax
		dey
		lda (dirptr),y
		ror
		lsr
		lsr
		lsr
		lsr
		
		jsr decoutz
		
		; +PrintChar '.'
		; year
		txa
		clc 
		adc #80   	; add begin of msdos epoch (1980)
		cmp #100	
		bcc @l6		; greater than 100 (post-2000)
		sec 		; yes, substract 100
		sbc #100
@l6:	jsr decoutz ; there we go

	
		lda #' '
		jsr krn_chrout


		ldy #DIR_WrtTime +1
		lda (dirptr),y
		tax
		lsr
		lsr
		lsr
	
		jsr decoutz

		lda #':'
		jsr krn_chrout


		txa
		and #%00000111
		sta tmp1
		dey
		lda (dirptr),y

		.repeat 5	
		lsr tmp1
		ror 
		.endrepeat

		jsr decoutz


	; Bits 11–15: Hours, valid value range 0–23 inclusive.
	crlf
	
		pla
		rts	

print_filename:
		ldy #DIR_Name
@l1:	lda (dirptr),y
		jsr krn_chrout
		iny
		cpy #$0b
		bne @l1
		rts



errmsg:
		jsr krn_hexout

		; +errMsgEntry fat_bad_block_signature, .fat_err_signature
		; +errMsgEntry fat_invalid_partition_type, .fat_err_partition
		; +errMsgEntry fat_invalid_sector_size, .fat_err_bad_sect_size
		; +errMsgEntry fat_invalid_num_fats, .fat_err_bad_sect_size		
		; +errMsgEntry fat_open_error, .fat_err_open
		; +errMsgEntry fat_too_many_files, .fat_err_too_many_open
		; +errMsgEntry fat_file_not_found, .fat_err_no_such_file
		; +errMsgEntry fat_file_not_open, .fat_err_file_not_open

		; jsr strout
		
		rts


; .hellotxt		!text "SteckShell 0.11 ",$00
helptxt1:
				.byte $0a,$0d,"ll/ls       - directory (long/short)"
				.byte $0a,$0d,"cd <name>   - change directory"
				; !text $0a,$0d,"run <name>  - run program"		
				.byte $0a,$0d,"dump <addr> <addr> - dump memory"
				.byte $00

; .crlf			!byte $0a,$0d,$00
; .prompt			!text $0a,$0d,">",$00

; .txt_msg_param_error	!text $0a,$0d,"parameter error",$0a,$0d,$00
; .txt_msg_sd_init_error	!text $0a,$0d,"sdcard init error",$0a,$0d,$00
; .txt_cd 				!text "cd ok",$00

; .fat_err_signature 		!text "bad block signature", $00
; .fat_err_partition 		!text "invalid partition type", $00
; .fat_err_bad_sect_size 	!text "sector size unsupported", $00
; .fat_err_open			!text "open error",$00
; .fat_err_no_such_file	!text "no such file or directory",$00
; .fat_err_file_not_open	!text "file not open error",$00
; .fat_err_too_many_open	!text "too many open files",$00
dir_entry:
		jmp (entryvec)

ls:
		lda #num_ls_entries
		sta entries
		SetVector dir_show_entry_short, entryvec

		bra l1
dir:
		SetVector dir_show_entry, entryvec
l1:
		crlf
		SetVector pattern, filenameptr

		lda (paramptr)
		beq @l2
		copypointer paramptr, filenameptr

@l2:
		jsr krn_find_first
		bcs @l4
		bra @l5
		; jsr .dir_show_entry
@l3:
		jsr krn_find_next
		bcc @l5
@l4:	
		lda (dirptr)
		cmp #$e5
		beq @l3

		ldy #DIR_Attr
		lda (dirptr),y

		bit dir_attrib_mask ; Hidden attribute set, skip
		bne @l3


		jsr dir_entry

		jsr krn_getkey
		cmp #$03 ; CTRL-C?
		beq @l5
		bra @l3
@l5:
		jmp mainloop


cd:
		; is it a slash?
		ldy #$00
		lda (paramptr),y
		cmp #'/'
		bne @l1
		iny
		lda (paramptr),y
		bne @l1
		
		; its a slash, nothing else. cd to /
		jsr krn_open_rootdir
		jmp mainloop

@l1:	; not a slash. cd to whatever

		jsr param2fileptr
		
		crlf
		
		jsr krn_open

		lda errno
		beq @l2
		jsr errmsg
		
		jmp mainloop
@l2:
		jsr krn_primm
		.asciiz "cd ok"
		jmp mainloop 


run:

		lda #<filename
		sta filenameptr
		lda #>filename
		sta filenameptr+1
		
		ldy #$00
@l1:	lda (cmdptr),y
		beq @l2
		sta filename,y
		cmp #' '
		beq @l2
		
		cmp #'.'
		beq @l4 ; has extension
		iny
		bra @l1

@l2:
		ldx #$00
@l3:	lda exec_extension,x
		sta filename,y
		iny
		inx
		cpx #$05
		bne @l3

	

@l4:
		; +copyPointer cmdptr, filenameptr
		jsr readfile		
		
		lda errno
		beq @l5
		jmp mainloop
@l5:

	
		jmp steckos_start



dumpvec 		= $c0
dumpvec_end   	= dumpvec
dumpvec_start 	= dumpvec+2

dump:
	; stz .dumpvec
	stz dumpvec+1
	stz dumpvec+2
	stz dumpvec+3

	ldy #$00
	ldx #$03
@l1:
		lda (paramptr),y
		beq @l2

		jsr atoi
		asl
		asl
		asl
		asl
		sta dumpvec,x

		iny
		lda (paramptr),y
		beq @l2
		jsr atoi
		ora dumpvec,x
		sta dumpvec,x
		dex
		iny
		cpy #$04
		bne @l1

		iny
		bra @l1

@l2:	cpy #$00
		bne @l3

		printstring "parameter error"
		
		bra @l8
@l3:

		crlf
		lda dumpvec_start+1
		jsr krn_hexout
		lda dumpvec_start
		jsr krn_hexout
		lda #':'
		jsr krn_chrout
		lda #' '
		jsr krn_chrout

		ldy #$00
@l4:	lda (dumpvec_start),y
		jsr krn_hexout 
		lda #' '
		jsr krn_chrout
		iny
		cpy #$08
		bne @l4

		lda #' '
		jsr krn_chrout
		
		ldy #$00
@l5:	lda (dumpvec_start),y
		cmp #$19
		bcs @l6
		lda #'.'
@l6:	jsr krn_chrout
		iny
		cpy #$08
		bne @l5

		lda dumpvec_start+1
		cmp dumpvec_end+1
		bne @l7
		lda dumpvec_start
		cmp dumpvec_end
		beq @l8
		bcs @l8

@l7:
		jsr krn_getkey
		cmp #$03
		beq @l8
		clc
		lda dumpvec_start

		adc #$08
		sta dumpvec_start
		lda dumpvec_start+1
		adc #$00
		sta dumpvec_start+1
		bra @l3

@l8:	jmp mainloop

readfile:

	jsr krn_open
	stx tmp5

	lda errno
	bne @l1


	SetVector steckos_start, sd_read_blkptr
	jsr krn_read

	ldx tmp5
	jsr krn_close
	rts

@l1:
		crlf
		ldy #$00
@l2:	lda (filenameptr),y
		beq @l3
		jsr krn_chrout
		iny
		bra @l2
@l3:
		lda #':'
		jsr krn_chrout	
		lda #' '
		jsr krn_chrout

		lda errno
		jsr errmsg
		; plp	
		rts


upload:
	sei
	jsr upload
    cli
	; jump to new code
	jmp (startaddr)	

hello:
	crlf
	jsr krn_primm
	.asciiz "SteckShell 0.12b"
	crlf
	jmp mainloop

help:
	crlf
	; +ShellPrintString .hellotxt
	SetVector helptxt1, msgptr
	jsr krn_strout
	jmp mainloop

init_textui:
	jsr	krn_display_off			;restore textui
	jsr	krn_textui_init
	jsr	krn_textui_enable
	rts
;----------------------------------------------------------------------------------------------
; decout - output byte in A as decimal ASCII without leading zeros
;----------------------------------------------------------------------------------------------
decout:
		phx
		phy
		ldx #1
		stx tmp1
		inx
		ldy #$40
@l1:
		sty tmp0
		lsr
@l2:	rol
		bcs @l3
		cmp dec_tbl,x
		bcc @l4
@l3:	sbc dec_tbl,x
		sec
@l4:	rol tmp0
		bcc @l2
		tay
		cpx tmp1
		lda tmp0
		bcc @l5
		beq @l6
		stx tmp1
@l5:	eor #$30
		jsr krn_chrout
@l6:	tya
		ldy #$10
		dex
		bpl @l1
		ply
		plx

		rts
decoutz:
		cmp #10
		bcs @l1
		pha
		lda #'0'
		jsr krn_chrout
		pla
@l1:	
		jmp decout
 
 ; Lookup table for decimal to ASCII
dec_tbl:			.byte 128,160,200


exec_extension:		.byte ".bin",$00
filename: 			.byte "            ",$00
pattern:			.byte "*.*",$00
