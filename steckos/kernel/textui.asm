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

.include "common.inc"
.include "kernel.inc"
.include "vdp.inc"

ROWS=24
.ifdef COLS80
COLS=80
.else
COLS=40
.endif
CURSOR_BLANK=' '
CURSOR_CHAR=$db ; invert blank char - @see charset_6x8.asm

KEY_CR=$0d
KEY_LF=$0a
KEY_BACKSPACE=$08
STATUS_BUFFER_DIRTY=1<<0
STATUS_CURSOR=1<<1
STATUS_TEXTUI_ENABLED=1<<2

.segment "OS_CACHE"
screen_buffer:      ;.res COLS*ROWS, CURSOR_BLANK
screen_status 		=   screen_buffer + (COLS*(ROWS+1))
screen_write_lock 	=   screen_status + 1
screen_frames		=   screen_status + 2
saved_char			=   screen_status + 3

.segment "KERNEL"
.export textui_init0, textui_update_screen, textui_chrout, textui_put

.ifdef TEXTUI_STROUT
.export textui_strout
.endif

.ifdef TEXTUI_PRIMM
.export textui_primm
.endif

.export textui_enable, textui_disable, textui_blank, textui_update_crs_ptr, textui_crsxy, textui_scroll_up
.import vdp_bgcolor, vdp_memcpy, vdp_mode_text, vdp_display_off

.macro _screen_dirty
		lda #STATUS_BUFFER_DIRTY
		tsb screen_status ;set dirty
.endmacro

textui_decy:
		lda	crs_y
		bne	@l1
		rts
@l1:	dec	crs_y			; go on with textui_update_crs_ptr below
		bra	textui_update_crs_ptr

textui_incx:
		lda	crs_x
		cmp	#(COLS-1)
		bne @l1
		rts					;TODO should we move to next row automatically ?!?
@l1:	inc	crs_x
		bra	textui_update_crs_ptr

textui_decx:
		lda	crs_x
		bne	@l1
		rts
@l1:	dec	crs_x			; go on with textui_update_crs_ptr below
textui_update_crs_ptr:		;   updates the 16 bit pointer crs_p upon crs_x, crs_y values
		pha

		lda saved_char     	;restore saved char
		sta (crs_ptr)
		lda #STATUS_CURSOR
		trb screen_status  	;reset cursor state

		;use the crs_ptr as tmp variable
		stz crs_ptr+1
		lda crs_y
		asl						; y*2
		asl						; y*4
		asl						; y*8

.ifdef COLS80					; crs_y*64 + crs_y*16 (crs_ptr) => y*80
		asl						; y*16
		sta crs_ptr
		php						; save carry
		rol crs_ptr+1	   	; save carry if overflow
.else
		; crs_y*32 + crs_y*8  (crs_ptr) => y*40
		sta crs_ptr				; save
		php						; save carry
.endif
		asl
		rol crs_ptr+1	   	; save carry if overflow
		asl
		rol crs_ptr+1			; save carry if overflow

		plp						; restore carry from overflow above
		bcc @l0
		inc crs_ptr+1
		clc

@l0:	adc crs_ptr	    		;
		bcc @l1
		inc crs_ptr+1		; overflow inc page count
		clc				;
@l1:	adc crs_x
		sta crs_ptr
		lda #>screen_buffer
		adc crs_ptr+1		; add carry and page to address high byte
		sta crs_ptr+1

		lda (crs_ptr)
		sta saved_char		;save char at new position

		pla
		rts

textui_init0:
		jsr	vdp_display_off			        ;display off



      SetVector screen_buffer, crs_ptr    ;set crs ptr initial to screen buffer
		jsr	textui_blank			        ;blank screen buffer
      stz screen_write_lock               ;reset write lock
      jsr textui_enable
textui_init:
		jmp vdp_mode_text

textui_blank:
		ldx #0
		lda #CURSOR_BLANK
		sta saved_char
@l1:	sta screen_buffer+$000,x	;4 pages, 40x24
		sta screen_buffer+$100,x
		sta screen_buffer+$200,x

.ifdef COLS80
		sta screen_buffer+$300,x
		sta screen_buffer+$400,x	;additional 4 pages for 80 cols
		sta screen_buffer+$500,x
		sta screen_buffer+$600,x
.endif
		inx
		bne @l1
@l2:
.ifndef COLS80
		sta screen_buffer+$300,x
.endif
.ifdef COLS80
		sta screen_buffer+$700,x
.endif
		inx
		cpx #<(COLS*(ROWS+1))
		bne @l2

    	stz 	crs_x
    	stz 	crs_y
      jsr	textui_update_crs_ptr

      _screen_dirty
		rts

textui_cursor:
		lda screen_write_lock
		bne @l2
		lda screen_frames
		and #$0f
		bne @l2
		lda #STATUS_CURSOR
		tsb screen_status
		beq @l1
		trb screen_status
		lda saved_char
		jmp textui_put
@l1:	lda #CURSOR_CHAR
		jmp textui_put
@l2:	rts

textui_update_screen:
;		lda	#Dark_Green
;		jsr	vdp_bgcolor

		lda	screen_status
		and	#STATUS_TEXTUI_ENABLED
		beq	@l1

		inc	screen_frames

		jsr	textui_cursor

		lda	screen_status
		and	#STATUS_BUFFER_DIRTY
		beq	@l1	;exit if not dirty

		SetVector	screen_buffer, addr    ; copy back buffer to video ram
		lda	#<ADDRESS_GFX1_SCREEN
		ldy	#WRITE_ADDRESS + >ADDRESS_GFX1_SCREEN
.ifdef COLS80
		ldx	#$08
.else
		ldx	#$04
.endif
		jsr	vdp_memcpy

		lda	screen_status		;clean dirty
		and	#<(~STATUS_BUFFER_DIRTY)
		sta	screen_status

@l1:
		lda	#Medium_Green<<4|Black
		jsr	vdp_bgcolor
		rts

textui_scroll_up:
		phx
		ldx	#$00
@l1:	lda	screen_buffer+$000+COLS,x
		sta	screen_buffer+$000,x
		inx
		bne	@l1
@l2:	lda	screen_buffer+$100+COLS,x
		sta	screen_buffer+$100,x
		inx
		bne	@l2
@l3:	lda	screen_buffer+$200+COLS,x
		sta	screen_buffer+$200,x
		inx
		bne	@l3
.ifndef COLS80
@le:	lda	screen_buffer+$300+COLS,x
		sta	screen_buffer+$300,x
		inx
      cpx #<(COLS * ROWS)
		bne	@le
.endif
.ifdef COLS80
@l4:	lda	screen_buffer+$300+COLS,x
		sta	screen_buffer+$300,x
		inx
		bne	@l4
@l5:	lda	screen_buffer+$400+COLS,x
		sta	screen_buffer+$400,x
		inx
		bne	@l5
@l6:	lda	screen_buffer+$500+COLS,x
		sta	screen_buffer+$500,x
		inx
		bne	@l6
@l7:	lda	screen_buffer+$600+COLS,x
		sta	screen_buffer+$600,x
		inx
		bne	@l7
@le:	lda	screen_buffer+$700+COLS,x
		sta	screen_buffer+$700,x
		inx
      cpx #<(COLS * ROWS)
		bne	@le
.endif

		plx
		rts

textui_incy:
inc_cursor_y:
		lda crs_y
		cmp	#ROWS-1			;last line
		bne	@l1

		lda saved_char		;restore saved char
		sta (crs_ptr)
		lda #CURSOR_BLANK
		sta saved_char     	;reset .saved_char to blank, cause we scrolled up
		lda #STATUS_CURSOR
		trb screen_status  ;reset cursor state
		jsr	textui_scroll_up	; scroll and exit
		jmp textui_update_crs_ptr
@l1:	inc crs_y
	   jmp textui_update_crs_ptr

textui_enable:
		lda	#STATUS_TEXTUI_ENABLED
		sta screen_status       ;set enable
        rts
textui_disable:
        stz screen_status
		rts

.ifdef TEXTUI_STROUT
;----------------------------------------------------------------------------------------------
; Output string on screen
; in:
;   A - lowbyte  of string address
;   X - highbyte of string address
;----------------------------------------------------------------------------------------------
textui_strout:
		sta krn_ptr3		;init for output below
		stx krn_ptr3+1

		inc screen_write_lock	;write on
		ldy	#$00
@l1:	lda	(krn_ptr3),y
		beq	@l2
		jsr textui_dispatch_char
		iny
		bne	@l1
@l2:	stz	screen_write_lock	;write off
		_screen_dirty

		rts
.endif

;----------------------------------------------------------------------------------------------
; Put the string following in-line until a NULL out to the console
; jsr primm
; .byte "Example Text!",$00
;----------------------------------------------------------------------------------------------
.ifdef TEXTUI_PRIMM
textui_primm:
		pla						; Get the low part of "return" address
		sta     krn_ptr3
		pla						; Get the high part of "return" address
		sta     krn_ptr3+1

		inc screen_write_lock
		; Note: actually we're pointing one short
PSINB:	inc     krn_ptr3             ; update the pointer
		bne     PSICHO          ; if not, we're pointing to next character
		inc     krn_ptr3+1             ; account for page crossing
PSICHO:	lda     (krn_ptr3)	        ; Get the next string character
		beq     PSIX1           ; don't print the final NULL
		jsr     textui_dispatch_char		; write it out
		bra     PSINB           ; back around
PSIX1:	inc     krn_ptr3             ;
		bne     PSIX2           ;
		inc     krn_ptr3+1             ; account for page crossing
PSIX2:
		stz screen_write_lock
		_screen_dirty

		jmp     (krn_ptr3)           ; return to byte following final NULL
.endif

textui_put:
		pha
		sta (crs_ptr)
		_screen_dirty
		pla
		rts

textui_chrout:
		beq	@l1	; \0 char
		pha		; safe char
		inc screen_write_lock	;write on
		jsr textui_dispatch_char
		stz	screen_write_lock	;write off
		_screen_dirty

		pla					; restore a
@l1:	rts



; set crs x and y position absolutely - 0..32/0..23 or 0..39/0..23 40 char mode
;
textui_crsxy:
		stx crs_x
		sty crs_y
		jmp textui_update_crs_ptr

textui_dispatch_char:
		cmp	#KEY_CR			;cariage return?
		bne	lfeed
		stz	crs_x
 	   	jmp textui_update_crs_ptr
lfeed:
		cmp	#KEY_LF			;line feed
		bne	@l1
		stz crs_x
 	   	jmp	inc_cursor_y
@l1:	cmp	#KEY_BACKSPACE
		bne	@l4
		lda	crs_x
		bne	@l3
		lda	crs_y			; cursor y=0, no dec
		beq	lupdate
		dec	crs_y
		lda	#(COLS-1)			; set x to end of line above
		sta	crs_x
@l2:	jsr	textui_update_crs_ptr
		lda	#CURSOR_BLANK			;blank the saved char
		sta	saved_char
    	rts
@l3:	dec	crs_x
    	bra @l2
@l4:
		sta	saved_char         ; the trick, simple set saved value to plot as saved char, will be print by textui_update_crs_ptr
		lda	crs_x
		cmp	#(COLS-1)
		beq @l5
		inc	crs_x
		jmp	textui_update_crs_ptr
@l5:	stz	crs_x
		jmp	inc_cursor_y
lupdate:
		jmp	textui_update_crs_ptr
