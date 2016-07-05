.include "kernel_jumptable.inc"

	lda #'A'
	jsr krn_chrout
loop:	jmp loop
