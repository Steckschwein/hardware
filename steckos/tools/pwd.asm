.include "kernel.inc"
.include "kernel_jumptable.inc"

.segment "CODE"

		lda	#<buffer
		ldx #>buffer
		sta msgptr		;init for output below
		stx msgptr
		ldy	#$ff
		jsr krn_getcwd
		
		;TODO FIXME use a/x instead of zp location msgptr
		jsr krn_strout
		jmp (retvec)
		
buffer:
	.res 256