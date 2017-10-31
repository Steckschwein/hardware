.include "kernel.inc"

.segment "KERNEL"
.export chrout, hexout, strout, primm
.import textui_chrout

;----------------------------------------------------------------------------------------------
; Output char on active output device
;----------------------------------------------------------------------------------------------
;chrout:     jmp textui_chrout
chrout = textui_chrout


;----------------------------------------------------------------------------------------------
; Output string on active output device
; in:
;   A - lowbyte  of string address
;   X - highbyte of string address
;----------------------------------------------------------------------------------------------
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

;----------------------------------------------------------------------------------------------
; Output byte as hex string on active output device
;----------------------------------------------------------------------------------------------

hexout:
		pha
		phx

		tax
		lsr
		lsr
		lsr
		lsr
		jsr hexdigit
		txa
		jsr hexdigit
		plx
		pla
		rts

hexdigit:
		and     #%00001111      ;mask lsd for hex print
		ora     #'0'            ;add "0"
		cmp     #'9'+1          ;is it a decimal digit?
		bcc     @l	            ;yes! output it
		adc     #6              ;add offset for letter a-f
@l:
		jmp 	chrout

;Put the string following in-line until a NULL out to the console
DPL		= msgptr
DPH		= msgptr+1

primm:
PUTSTRI:
		pla						; Get the low part of "return" address
                                ; (data start address)
		sta     DPL
		pla
		sta     DPH             ; Get the high part of "return" address
                                ; (data start address)
		; Note: actually we're pointing one short
PSINB:	inc     DPL             ; update the pointer
		bne     PSICHO          ; if not, we're pointing to next character
		inc     DPH             ; account for page crossing
PSICHO:	lda     (DPL)	        ; Get the next string character
		beq     PSIX1           ; don't print the final NULL
		jsr     chrout		; write it out
		bra     PSINB           ; back around
PSIX1:	inc     DPL             ;
		bne     PSIX2           ;
		inc     DPH             ; account for page crossing
PSIX2:	jmp     (DPL)           ; return to byte following final NULL
