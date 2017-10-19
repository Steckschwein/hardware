.include "zeropage.inc"

.export	_debugout
.export	_debugout8
.export	_debugout16
.export	_debugout32
.export _debugdump

.export _debugdirentry

.import	krn_chrout, krn_hexout, krn_primm

.segment "KERNEL"

dbg_acc				= $02f9 ; basic uses $0290 - $02f8
dbg_xreg			= $02fa
dbg_yreg			= $02fb
dbg_status			= $02fc
dbg_bytes			= $02fd
dbg_savept			= $02fe
dbg_return			= $028e

__dbg_ptr=$0

_debugout_enter:
		sta dbg_acc
		stx dbg_xreg
		sty dbg_yreg
		php
		pla
		sta dbg_status
		cld
		
		lda 	__dbg_ptr
		sta 	dbg_savept
		lda 	__dbg_ptr+1
		sta 	dbg_savept+1
		
		stz dbg_bytes
		jsr krn_primm
		.asciiz "AXYP "
		lda dbg_acc
		jsr krn_hexout
		lda dbg_xreg 
		jsr krn_hexout
		lda dbg_yreg
		jsr krn_hexout
		lda dbg_status
		jsr krn_hexout
		lda	#' '
		jmp krn_chrout
		
_debugdirentry:
		jsr 	_debugout_enter
		ldy #0
	@l0:
		lda (dirptr),y
		jsr krn_hexout
		lda #' '
		jsr krn_chrout
		iny 
		cpy #32
		bne @l0
		bra _debugoutnone
		
_debugdumpptr:
;		jsr 	_debugout_enter
;		lda 	#11
;		bra		_debugout0		
_debugdump:
		jsr 	_debugout_enter
		lda 	#11
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
_debugoutnone:		
		lda		#$ff
_debugout0:
		sta		dbg_bytes
		pla							; Get the low part of "return" address
									; (data start address)
		sta     dbg_return
		sta 	__dbg_ptr
		pla
		sta     dbg_return+1  	 	; Get the high part of "return" address
		sta 	__dbg_ptr+1			; (data start address)

		ldy 	dbg_bytes			; bytes to output
		bmi		@PSINB

		ldy		#2					; 2 byte address argument
		lda 	(__dbg_ptr),y
		tax
		dey
		lda 	(__dbg_ptr),y
		sta		__dbg_ptr			; address is setup in __dbg_ptr
		stx		__dbg_ptr+1

		ldy 	dbg_bytes			; bytes to output
		lda		__dbg_ptr+1
		jsr 	krn_hexout
		lda		__dbg_ptr
		jsr 	krn_hexout
		lda		#' '
		jsr 	krn_chrout
@l1:	lda		(__dbg_ptr),y
		jsr 	krn_hexout
		lda 	#' '
		jsr 	krn_chrout
		dey
		bpl		@l1
		lda		#' '
		jsr 	krn_chrout

		clc 
		lda		dbg_return		; restore address for message argument
		adc		#2				; +2 - 16bit debug address argument
								; Note: actually we're pointing one short
		sta 	__dbg_ptr		;
		lda 	dbg_return+1
		adc 	#0
		sta		__dbg_ptr+1	

@PSINB:							; Note: actually we're pointing one short
		inc     __dbg_ptr       ; update the pointer
		bne     @PSICHO         ; if not, we're pointing to next character
		inc     __dbg_ptr+1		; account for page crossing
		
@PSICHO:lda     (__dbg_ptr)	    ; Get the next string character
		beq     @PSIX1          ; don't print the final NULL
		jsr     krn_chrout		; write it out
		bra     @PSINB          ; back around
@PSIX1:	inc     __dbg_ptr  		;
		bne     @PSIX2      	;
		inc     __dbg_ptr+1     ; account for page crossing
@PSIX2:	lda		#$0a			; line feed
		jsr 	krn_chrout

		lda		__dbg_ptr		; __dbg_ptr points to instruction after msg, adjust ret vector
		sta 	dbg_return
		lda		__dbg_ptr+1
		sta 	dbg_return+1
		
		lda 	dbg_savept		; restore
		sta 	__dbg_ptr
		lda 	dbg_savept+1
		sta 	__dbg_ptr+1

		lda 	dbg_status
		pha
		lda		dbg_acc
		ldx		dbg_xreg
		ldy		dbg_yreg
		plp
		
		jmp     (dbg_return)           ; return to byte following final NULL