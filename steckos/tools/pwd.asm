.include "kernel.inc"
.include "kernel_jumptable.inc"

.segment "CODE"

		lda	#<buffer
		ldx #>buffer
		ldy	#$ff
		jsr krn_getcwd
		bne	@l_err
		lda	#<buffer
		ldx #>buffer
		sta msgptr		;init for output below
		stx msgptr+1
		;TODO FIXME use a/x instead of zp location msgptr
		jsr krn_strout
		
@l2:	jmp (retvec)

@l_err:	
		pha
		lda #'E'
		jsr krn_chrout
		pla
		jsr krn_hexout
		bra @l2

buffer:
	.res 255

.segment "INITBSS"	
.segment "ZPSAVE"
.segment "STARTUP"