dir_attrib_mask		= $0a
.segment "CODE"
.include "../kernel/kernel.inc"
.include "../kernel/kernel_jumptable.inc"
.include "../kernel/fat32.inc"

tmp0    = $a0
tmp1    = $a1
tmp5    = $a2

main:

		

l1:
		crlf
		SetVector pattern, filenameptr

		lda (paramptr)
		beq @l2
		copypointer paramptr, filenameptr

@l2:
        ldx #0
		jsr krn_find_first
        lda errno
        beq @l2_1
        printstring "i/o error"
        jmp (retvec)
        
@l2_1:	bcs @l4
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

		bit #dir_attrib_mask ; Hidden attribute set, skip
		bne @l3

		jsr dir_show_entry

		jsr krn_getkey
		cmp #$03 ; CTRL-C?
		beq @l5
		bra @l3
@l5:


	jmp (retvec)


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

pattern:			.byte "*.*",$00


