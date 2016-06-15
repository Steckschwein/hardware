
.segment "BIOS"
.export hexout, primm, print_crlf
.import vdp_chrout
.include "bios.inc"

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
		jmp		vdp_chrout

;Put the string following in-line until a NULL out to the console
primm:
PUTSTRI: 
		pla			; Get the low part of "return" address
                                ; (data start address)
        sta     DPL
        pla
        sta     DPH             ; Get the high part of "return" address
                                ; (data start address)
        ; Note: actually we're pointing one short
PSINB:  ldy     #1
        lda     (DPL),y         ; Get the next string character
        inc     DPL             ; update the pointer
        bne     PSICHO          ; if not, we're pointing to next character
        inc     DPH             ; account for page crossing
PSICHO: ora     #0              ; Set flags according to contents of
                                ;    Accumulator
        beq     PSIX1           ; don't print the final NULL
        jsr     vdp_chrout         ; write it out
        bra     PSINB           ; back around
PSIX1:  inc     DPL             ;
        bne     PSIX2           ;
        inc     DPH             ; account for page crossing
PSIX2:  jmp     (DPL)           ; return to byte following final NULL

print_crlf:
		pha
		lda #$0a
		jsr vdp_chrout
		lda #$0d
		jsr vdp_chrout
		pla
		rts
