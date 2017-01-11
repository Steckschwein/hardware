.include	"common.inc"
.include	"../kernel/zeropage.inc"
.include	"../kernel/kernel_jumptable.inc"


main:
	jsr krn_keyin
	pha
	jsr krn_primm
	.byte $0a,"0x",0
	pla
	jsr	krn_hexout	
	jmp (retvec)
