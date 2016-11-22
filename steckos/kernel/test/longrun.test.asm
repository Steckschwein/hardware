.include 	"../kernel_jumptable.inc"

@l0:		ldx #0
@l1:		lda	msg, x
			beq	@l0
			jsr	krn_chrout
			inx
			bne @l1
			jmp @l0
msg:
.byte		"Hello World!",$0a,0