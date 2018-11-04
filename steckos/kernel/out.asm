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

.include "kernel.inc"

.segment "KERNEL"
.export chrout, strout, primm
.import textui_chrout

.ifdef TEXTUI_STROUT
.import textui_strout
.endif

.ifdef TEXTUI_PRIMM
.import textui_primm
.endif

;----------------------------------------------------------------------------------------------
; Output char on active output device
; in:
;  A - char to output
;----------------------------------------------------------------------------------------------
;chrout:     jmp textui_chrout
chrout = textui_chrout

;----------------------------------------------------------------------------------------------
; Output string on active output device
; in:
;   A - lowbyte  of string address
;   X - highbyte of string address
;----------------------------------------------------------------------------------------------
.ifdef TEXTUI_STROUT
strout = textui_strout
.else
strout:
		sta krn_ptr3		;init for output below
		stx krn_ptr3+1
		pha                 ;save a, y to stack
		phy

		ldy #$00
@l1:	lda (krn_ptr3),y
		beq @l2
		jsr chrout
		iny
		bne @l1

@l2:	ply                 ;restore a, y
		pla
		rts
.endif



;----------------------------------------------------------------------------------------------
; Put the string following in-line until a NULL out to the console
; jsr primm
; .byte "Example Text!",$00
;----------------------------------------------------------------------------------------------
.ifdef TEXTUI_PRIMM
primm = textui_primm
.else
primm:
		pla						; Get the low part of "return" address
                                ; (data start address)
		sta     krn_ptr3
		pla
		sta     krn_ptr3+1             ; Get the high part of "return" address
                                ; (data start address)
		; Note: actually we're pointing one short
PSINB:	inc     krn_ptr3             ; update the pointer
		bne     PSICHO          ; if not, we're pointing to next character
		inc     krn_ptr3+1             ; account for page crossing
PSICHO:	lda     (krn_ptr3)	        ; Get the next string character
		beq     PSIX1           ; don't print the final NULL
		jsr     chrout		; write it out
		bra     PSINB           ; back around
PSIX1:	inc     krn_ptr3             ;
		bne     PSIX2           ;
		inc     krn_ptr3+1             ; account for page crossing
PSIX2:	jmp     (krn_ptr3)           ; return to byte following final NULL
.endif
