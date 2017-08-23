.include	"common.inc"
.include	"../kernel/zeropage.inc"
.include	"../kernel/kernel_jumptable.inc"

__LOADADDR__ = $1000
.export __LOADADDR__
.segment "LOADADDR"
.word __LOADADDR__
.segment "CODE"



main:
@0:
	jsr krn_getkey
	beq	@0
	pha
	jsr krn_primm
	.byte $0a,"0x",0
	pla
	jsr	krn_hexout	
	jmp (retvec)
