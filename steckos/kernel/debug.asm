.ifdef DEBUG

.include "zeropage.inc"

.export	_debugout
.export	_debugout8
.export	_debugout16
.export	_debugout32
.export _debugdump

.import	krn_chrout, krn_hexout, krn_primm

.segment "KERNEL"

_debugout_enter:
		sta dbg_acc
		stx dbg_xreg
		sty dbg_yreg
		php
		pla
		sta dbg_status
		cld
		
		lda 	krn_ptr1
		sta 	dbg_savept
		lda 	krn_ptr1+1
		sta 	dbg_savept+1
		
		stz dbg_bytes
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
		
_debugdump:
		jsr 	_debugout_enter
		lda 	#$1f
		bra		_debugout0		
_debugout32:
		jsr 	_debugout_enter
		lda 	#3
		bra		_debugout0
_debugout16:
		jsr 	_debugout_enter
		lda		#1
		bra		_debugout0
_debugout8:
		jsr 	_debugout_enter
		lda		#0
		bra		_debugout0
_debugout:
		jsr 	_debugout_enter
		lda		#$ff
_debugout0:
		sta		dbg_bytes
		pla						; Get the low part of "return" address
                                ; (data start address)
		sta     msgptr
		pla
		sta     msgptr+1       ; Get the high part of "return" address
                                ; (data start address)
						
		ldy		#2
		lda 	(msgptr),y
		sta 	krn_ptr1+1
		dey
		lda 	(msgptr),y
		sta		krn_ptr1			; read debug address

		ldy 	dbg_bytes			; bytes hex out
		bmi		@PSINB
		lda		krn_ptr1+1
		jsr 	krn_hexout
		lda		krn_ptr1
		jsr 	krn_hexout
		lda		#' '
		jsr 	krn_chrout
@l1:	lda		(krn_ptr1),y
		jsr 	krn_hexout
		lda 	#' '
		jsr 	krn_chrout
		dey
		bpl		@l1
		lda		#' '
		jsr 	krn_chrout

		clc 
		lda		#2
		adc		msgptr			; +2 cause of saved debug ptr
		sta 	msgptr
		bcc     @PSINB
		inc     msgptr+1		
		
@PSINB:							; Note: actually we're pointing one short
		inc     msgptr         ; update the pointer
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

		lda 	dbg_savept
		sta 	krn_ptr1
		lda 	dbg_savept+1
		sta 	krn_ptr1+1

		lda 	dbg_status
		pha
		lda		dbg_acc
		ldx		dbg_xreg
		ldy		dbg_yreg
		plp
		jmp     (msgptr)           ; return to byte following final NULL
.endif