.include	"common.inc"
.include	"../kernel/zeropage.inc"
.include	"../kernel/kernel_jumptable.inc"


main:
	jsr krn_primm
	.byte $0a,0
	jsr krn_keyin
	jsr	krn_hexout
	jmp (retvec)
