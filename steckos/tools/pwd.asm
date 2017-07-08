.include "kernel.inc"
.include "kernel_jumptable.inc"

.segment "CODE"

		lda	#<buffer
		ldx #>buffer
		sta msgptr		;init for output below
		stx msgptr+1
		ldy	#$ff
		jsr krn_getcwd
		beq	@l1
		pha
		lda #'E'
		jsr krn_chrout
		pla
		jsr krn_hexout
		bra @l2
		;TODO FIXME use a/x instead of zp location msgptr
@l1:	jsr krn_strout
@l2:	jmp (retvec)
		
buffer:
	.asciiz "1234567890"
	.res 256

.segment "INITBSS"	
.segment "ZPSAVE"
.segment "STARTUP"