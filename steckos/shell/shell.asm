; MIT License
;
; Copyright (c) 2018 Thomas Woinke, Marko Lauke, www.steckschwein.de
;
; Permission is hereby granted, free of charge, to any person obtaining a copy
; of this software and associated documentation files (the "Software"), to deal
; in the Software without restriction, including without limitation the rights
; to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
; copies of the Software, and to permit persons to whom the Software is
; furnished to do so, subject to the following conditions:
;
; The above copyright notice and this permission notice shall be included in all
; copies or substantial portions of the Software.
;
; THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
; IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
; FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
; AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
; LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
; OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
; SOFTWARE.

tmp0    = $a0
tmp1    = $a1
tmp5    = $a2

prompt  = $af

.include "common.inc"
.include "rtc.inc"
.include "../kernel/kernel.inc"
.include "../kernel/kernel_jumptable.inc"

.include "appstart.inc"
appstart $d800

; set attrib mask. hide volume label and hidden files
dir_attrib_mask		= $0a

KEY_RETURN 		= $0d
KEY_BACKSPACE 		= $08
KEY_CRSR_UP 		= $1E
KEY_CRSR_DOWN 	 	= $1F
KEY_CRSR_RIGHT 	 	= $10
KEY_CRSR_LEFT 	 	= $11

BUF_SIZE		= 32 ;TODO FIXME too hard
bufptr			= $d0
pathptr			= $d2
p_history   = $d4
; Address pointers for serial upload
startaddr		= $d9

SCREENSAVER_TIMEOUT_MINUTES=2

;---------------------------------------------------------------------------------------------------------
; init shell
;  - print welcome message
;---------------------------------------------------------------------------------------------------------

.import hexout
.export char_out=krn_chrout

.code
init:
		SetVector exit_from_prg, retvec
		SetVector buf, bufptr
		SetVector buf, paramptr ; set param to empty buffer
    SetVector msgbuf, msgptr
		SetVector PATH, pathptr

		jsr krn_primm
		.byte $0a, "steckOS Shell "
		.include "version.inc"
		.byte $0a,0
        
		bra mainloop

exit_from_prg:
		; cmp #0
		; beq mainloop
		; pha
		; jsr krn_primm
		; .byte $0a,"Exit: ",0
		; pla
		; jsr char_out

mainloop:
      crlf
      lda #'['
      jsr char_out
      ; output current path
      lda	#<msgbuf
      ldx #>msgbuf
      ldy	#$ff
      jsr krn_getcwd
      bne @nocwd

      lda #<msgbuf
      ldx #>msgbuf
      jsr krn_strout
      lda #']'
      jsr char_out
@nocwd:
        ; output prompt character
        lda #prompt
        jsr char_out
        
        lda crs_x
        sta crs_x_prompt
        
        ; reset input buffer
        lda #0
        tay
        sta (bufptr)

		; put input into buffer until return is pressed
inputloop:
        jsr screensaver_settimeout  ;reset timeout
@l_input:
        jsr screensaver_loop
        
        jsr krn_getkey
        bcc @l_input

        cmp #KEY_RETURN ; return?
        beq parse

        cmp #KEY_BACKSPACE
        beq backspace

        cmp #KEY_ESCAPE
        beq escape
        
        cmp #KEY_CRSR_UP
        beq key_crs_up
        
        cmp #KEY_CRSR_DOWN
        beq key_crs_down

        ; prevent overflow of input buffer
        cpy #BUF_SIZE
        beq inputloop
        
        sta (bufptr),y
        iny
line_end:
        jsr char_out
        jsr terminate

        bra inputloop

backspace:
        cpy #$00
        beq inputloop
        dey        
        bra line_end

escape:
        jsr krn_getkey
        jsr printbuf
        bra inputloop
        
key_crs_up:
        jsr history_back
        bra inputloop
        
key_crs_down:
        jsr history_frwd
        bra inputloop
    
terminate:
        lda #0
        sta (bufptr),y
        rts

parse:
        copypointer bufptr, cmdptr
        
        jsr history_push

        ; find begin of command word
@l1:
        lda (cmdptr)	; skip non alphanumeric stuff
        bne @l2
        jmp mainloop
@l2:
        cmp #$20
        bne @l3
        inc cmdptr
        bra @l1
@l3:
        copypointer cmdptr, paramptr

		; find begin of parameter (everything behind the command word, separated by space)
		; first, fast forward until space or abort if null (no parameters then)
@l4:	
      lda (paramptr)
      beq @l7
      cmp #$20
      beq @l5
      inc paramptr
      bra @l4
@l5:
		; space found.. fast forward until non space or null
@l6:	
      lda (paramptr)
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

		crlf
		jmp run

@l1:	jmp mainloop

history_frwd:
        lda p_history
        ;cmp #<(history+$0100)
        cmp p_history_end
        bne @inc_hist_ptr
        lda p_history+1
        ;cmp #>(history+$0100)
        cmp p_history_end+1
        bne @inc_hist_ptr
        rts
@inc_hist_ptr:
        lda p_history
        clc
        adc #BUF_SIZE
        sta p_history
        bra history_peek
        
history_back:
        lda p_history+1
        cmp #>history
        bne @dec_hist_ptr
        lda p_history
        cmp #<history
        bne @dec_hist_ptr
        rts
@dec_hist_ptr:
        sec ;dec hist ptr
        sbc #BUF_SIZE
        sta p_history
        
history_peek:
        lda crs_x_prompt
        sta crs_x
        jsr krn_textui_update_crs_ptr
        
        ldy #0
        ldx #BUF_SIZE
:       lda (p_history), y
        sta (bufptr), y
        beq :+
        jsr char_out
        iny
        dex 
        bpl :-
        
:       phy       ;safe y pos in buffer
        ldy crs_x ;safe crs_x position after restored cmd to y
        
        lda #' '  ;erase the rest of the line
:
        jsr char_out
        dex
        bpl :-
        sty crs_x 
        jsr krn_textui_update_crs_ptr
        ply       ;restore y buffer index
        rts
        
history_push:
        lda #$0a
        ;jsr char_out
        
        tya
        tax
        ldy #0
:       lda (bufptr), y
        sta (p_history), y
        ;jsr char_out
        iny
        dex
        bpl :-
        
        lda #$0a
        ;jsr char_out
        
        inc hist_e
        lda hist_e
        cmp #
        lda p_history   ; new end
        clc
        adc #BUF_SIZE
        sta p_history
        rts

printbuf:
		ldy #$01
		sty crs_x
		jsr krn_textui_update_crs_ptr

		ldy #$00
@l1:	lda (bufptr),y
		beq @l2
		sta buf,y
		jsr char_out
		iny
		bra @l1
@l2:	rts


cmdlist:

		.byte "cd",0
		.word cd

		.byte "up",0
		.word krn_upload

.ifdef DEBUG
		.byte "dump",0
		.word dump
.endif
		; End of list
		.byte $ff

.ifdef DEBUG

atoi:
		cmp #'9'+1
		bcc @l1 	; 0-9?
		; must be hex digit
		adc #$08
		and #$0f
		rts

@l1:		sec
		sbc #$30
		rts
.endif


errmsg:
		;TODO FIXME maybe use oserror() from cc65 lib
		cmp #$f1
		bne @l1

		jsr krn_primm
		.byte $0a,"invalid command",$0a,$00
		jmp mainloop

@l1:	cmp #$f2
		bne @l2

		jsr krn_primm
		.byte $0a,"invalid directory",$0a,$00
		jmp mainloop

@l2:
		jsr krn_primm
		.byte $0a,"unknown error",$0a,$00
		jmp mainloop


cd:
    	lda paramptr
    	ldx paramptr+1
    	jsr krn_chdir
		beq @l2
		lda #$f2 ; invalid dir
		jmp errmsg
@l2:
		jmp mainloop

run:
		lda cmdptr
		ldx cmdptr+1    ; cmdline in a/x
		jsr krn_execv   ; return A with errorcode
		bne @l1         ; error? try different path
		jmp mainloop

@l1:
		stz tmp0
@try_path:
		ldx #0
		ldy tmp0
@cp_path:
		lda (pathptr), y
		beq @check_path
		cmp #':'
		beq @cp_next
		sta tmpbuf,x
		inx
		iny
		bne @cp_path
		lda #$f0
		jmp errmsg
@check_path:    ;PATH end reached and nothing to prefix
		cpy tmp0
		bne @cp_next_piece  ;end of path, no iny
		lda #$f1        ;nothing found, "Invalid command"
		jmp errmsg
@cp_next:
		iny
@cp_next_piece:
		sty tmp0        ;safe PATH offset, 4 next try
		stz	tmp1
		ldy #0
@cp_loop:
		lda (cmdptr),y
		beq @l3
		cmp #'.'
		bne	@cp_loop_1
		stx	tmp1
@cp_loop_1:
		cmp #' '		;end of program name?
		beq @l3
		sta tmpbuf,x
		iny
		inx
		bne @cp_loop
@l3:	lda tmp1
		bne	@l4
		ldy #0
@l5:	lda	APPEXT,y
		beq @l4
		sta tmpbuf,x
		inx
		iny
		bne	@l5
@l4:	stz tmpbuf,x
		lda #<tmpbuf
		ldx #>tmpbuf    ; cmdline in a/x
		jsr krn_execv   ; return A with errorcode
		bne @try_path
		lda #$fe
		jmp errmsg


.ifdef DEBUG
dumpvec		= $c0
dumpvec_end   	= dumpvec
dumpvec_start 	= dumpvec+2

dump:
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
		jsr hexout
		lda dumpvec_start
		jsr hexout
		lda #':'
		jsr char_out
		lda #' '
		jsr char_out

		ldy #$00
@l4:	lda (dumpvec_start),y
		jsr hexout
		lda #' '
		jsr char_out
		iny
		cpy #$08
		bne @l4

		lda #' '
		jsr char_out

		ldy #$00
@l5:	lda (dumpvec_start),y
		cmp #$19
		bcs @l6
		lda #'.'
@l6:	jsr char_out
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
.endif

screensaver_loop:
        lda rtc_systime_t+time_t::tm_min
        cmp screensaver_rtc
        bne l_exit
        lda #<screensaver_prg
		ldx #>screensaver_prg
        phy
		jsr krn_execv   ;ignore any errors
        ply
screensaver_settimeout:
        lda rtc_systime_t+time_t::tm_min
        clc
        adc #SCREENSAVER_TIMEOUT_MINUTES
        cmp #60
        bcc :+
        sbc #60
:       sta screensaver_rtc
l_exit:
        rts
crs_x_prompt: .res 1

PATH:     .asciiz "./:/bin/:/sbin/:/usr/bin/"
APPEXT:   .asciiz ".PRG"
screensaver_prg:  .asciiz "/usr/bin/unrclock.prg"
screensaver_rtc:  .res 1
hist_s  .res 1, 0
hist_e  .res 1, 0
hist_r  .res 1, 0
tmpbuf:
buf = tmpbuf + 64
msgbuf = buf + BUF_SIZE

history=msgbuf+$100