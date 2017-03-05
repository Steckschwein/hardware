.ifdef DEBUG

.include "zeropage.inc"
.export	_debugout
.import	krn_chrout, krn_hexout, krn_primm

.segment "KERNEL"

_debugout:
		sta dbg_acc
		stx dbg_xreg
		sty dbg_yreg
		php
		pla
		sta dbg_status
		cld
		jsr krn_primm
		.asciiz "AXY: "
		lda dbg_acc
		jsr krn_hexout
		lda dbg_xreg 
		jsr krn_hexout
		lda dbg_yreg
		jsr krn_hexout
		lda	#' '
		jsr krn_chrout
		
		pla						; Get the low part of "return" address
                                ; (data start address)
		sta     msgptr
		pla
		sta     msgptr+1       	; Get the high part of "return" address
                                ; (data start address)				
@PSINB:	ldy     #1				; Note: actually we're pointing one short
		lda     (msgptr),y      ; Get the next string character
		inc     msgptr          ; update the pointer
		bne     @PSICHO         ; if not, we're pointing to next character
		inc     msgptr+1		; account for page crossing
@PSICHO:ora     #0          	; Set flags according to contents of
                               	;    Accumulator
		beq     @PSIX1          ; don't print the final NULL
		jsr     krn_chrout		; write it out
		bra     @PSINB          ; back around
@PSIX1:	inc     msgptr  		;
		bne     @PSIX2      	;
		inc     msgptr+1         ; account for page crossing
@PSIX2:	lda	#$0a
		jsr krn_chrout

		lda 	dbg_status
		pha
		lda		dbg_acc
		ldx		dbg_xreg
		ldy		dbg_yreg
		plp
		jmp     (msgptr)           ; return to byte following final NULL
.endif