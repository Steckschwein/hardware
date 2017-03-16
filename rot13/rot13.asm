.include "../steckos/kernel/kernel.inc"
.include "../steckos/kernel/kernel_jumptable.inc"
.include "../steckos/asminc/common.inc"


main:
	lda #$0a
	jsr krn_chrout

	ldx #$00
@loop:
	jsr krn_keyin
	cmp #$0d
	beq out
	jsr krn_chrout
	sta buf,x
	inx
	stz buf,x
	bra @loop

	
out:	
	lda #$0a
	jsr krn_chrout

	ldx #$00
@loop:
	lda buf,x
	beq main

	ldy #51
@l:
	cmp table_a,y
	beq @lookup
	dey
	bpl @l
	
	
	bra @output
	
@lookup:
	lda table_r,y

@output:
	jsr krn_chrout
	inx
	bra @loop
	

table_a:
	.byte "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz"
table_r:
	.byte "NOPQRSTUVWXYZABCDEFGHIJKLMnopqrstuvwxyzabcdefghijklm"
	
buf:
