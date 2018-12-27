.include	"common.inc"
.include	"../kernel/zeropage.inc"
.include	"../kernel/kernel_jumptable.inc"
.include 	"appstart.inc"
appstart $1000

.import hexout

.export char_out=krn_chrout

main:
@0:
	jsr krn_getkey
	beq	@0
	pha
	jsr krn_primm
	.byte $0a,"0x",0
	pla
	jsr	hexout
	jmp (retvec)
