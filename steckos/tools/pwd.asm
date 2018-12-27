.include "kernel.inc"
.include "kernel_jumptable.inc"
.import hexout

.export char_out=krn_chrout

.segment "CODE"

		lda	#<buffer
		ldx #>buffer
		ldy	#$ff
		jsr krn_getcwd
		bne	@l_err
		lda	#<buffer
		ldx #>buffer
		;TODO FIXME use a/x instead of zp location msgptr
		jsr krn_strout

@l2:	jmp (retvec)

@l_err:
		pha
		lda #'E'
		jsr krn_chrout
		pla
		jsr hexout
		bra @l2



buffer:
	.res 255

.segment "INITBSS"
.segment "ZPSAVE"
.segment "STARTUP"
