.ifdef DEBUG

.include "zeropage.inc"

.export	_debugout
.export	_debugout32
.import	krn_chrout, krn_hexout, krn_primm

dbg_acc			= $0290
dbg_xreg		= $0291
dbg_yreg		= $0292
dbg_status		= $0293

.segment "KERNEL"

_debugout_enter:
		sta dbg_acc
		stx dbg_xreg
		sty dbg_yreg
		php
		pla
		sta dbg_status
		cld
		jsr krn_primm
		.asciiz "AXY "
		lda dbg_acc
		jsr krn_hexout
		lda dbg_xreg 
		jsr krn_hexout
		lda dbg_yreg
		jsr krn_hexout
		lda	#' '
		jmp krn_chrout
_debugout_restore:
		

_debugout32:
		jsr _debugout_enter
		
_debugout:
		jsr _debugout_enter
		
		pla						; Get the low part of "return" address
                                ; (data start address)
		sta     msgptr
		pla
		sta     msgptr+1       	; Get the high part of "return" address
                                ; (data start address)
;		ldy 	#03				; 32bit value
;@l1:	lda		(msgptr),y
;		jsr 	krn_hexout
;		dey
;		bpl		@l1
		
@PSINB:							; Note: actually we're pointing one short
		inc     msgptr          ; update the pointer
		bne     @PSICHO         ; if not, we're pointing to next character
		inc     msgptr+1		; account for page crossing
		
@PSICHO:lda     (msgptr)	    ; Get the next string character
		beq     @PSIX1          ; don't print the final NULL
		jsr     krn_chrout		; write it out
		bra     @PSINB          ; back around
@PSIX1:	inc     msgptr  		;
		bne     @PSIX2      	;
		inc     msgptr+1        ; account for page crossing
@PSIX2:	lda		#$0a			; line feed
		jsr 	krn_chrout

		lda 	dbg_status
		pha
		lda		dbg_acc
		ldx		dbg_xreg
		ldy		dbg_yreg
		plp
		jmp     (msgptr)           ; return to byte following final NULL
.endif