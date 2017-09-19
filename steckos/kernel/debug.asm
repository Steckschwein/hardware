.ifdef DEBUG

.include "zeropage.inc"

.export	_debugout
.export	_debugout8
.export	_debugout16
.export	_debugout32
.export _debugdump

.import	krn_chrout, krn_hexout, krn_primm

dbg_acc			= $0293
dbg_xreg		= $0294
dbg_yreg		= $0295
dbg_status		= $0296
dbg_bytes		= $0297

dbg_ptr			= $dc
dbg_ptr2		= $de

.segment "KERNEL"

_debugout_enter:
		sta dbg_acc
		stx dbg_xreg
		sty dbg_yreg
		php
		pla
		sta dbg_status
		cld
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
		sta     dbg_ptr
		pla
		sta     dbg_ptr+1       ; Get the high part of "return" address
                                ; (data start address)
						
		ldy		#2
		lda 	(dbg_ptr),y
		sta 	dbg_ptr2+1
		dey
		lda 	(dbg_ptr),y
		sta		dbg_ptr2			; read debug address

		ldy 	dbg_bytes			; bytes hex out
		bmi		@PSINB
		lda		dbg_ptr2+1
		jsr 	krn_hexout
		lda		dbg_ptr2
		jsr 	krn_hexout
		lda		#' '
		jsr 	krn_chrout
@l1:	lda		(dbg_ptr2),y
		jsr 	krn_hexout
		lda 	#' '
		jsr 	krn_chrout
		dey
		bpl		@l1
		lda		#' '
		jsr 	krn_chrout

		clc 
		lda		#2
		adc		dbg_ptr			; +2 cause of saved debug ptr
		sta 	dbg_ptr
		bcc     @PSINB
		inc     dbg_ptr+1		
		
@PSINB:							; Note: actually we're pointing one short
		inc     dbg_ptr         ; update the pointer
		bne     @PSICHO         ; if not, we're pointing to next character
		inc     dbg_ptr+1		; account for page crossing
		
@PSICHO:lda     (dbg_ptr)	    ; Get the next string character
		beq     @PSIX1          ; don't print the final NULL
		jsr     krn_chrout		; write it out
		bra     @PSINB          ; back around
@PSIX1:	inc     dbg_ptr  		;
		bne     @PSIX2      	;
		inc     dbg_ptr+1        ; account for page crossing
@PSIX2:	lda		#$0a			; line feed
		jsr 	krn_chrout

		lda 	dbg_status
		pha
		lda		dbg_acc
		ldx		dbg_xreg
		ldy		dbg_yreg
		plp
		jmp     (dbg_ptr)           ; return to byte following final NULL
.endif