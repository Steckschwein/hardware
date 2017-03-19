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
	sta buf,x
	inx
	stz buf,x
	jsr krn_chrout
	bra @loop

	
out:	
	lda #$0a
	jsr krn_chrout

	ldx #$00
@loop:
	lda buf,x
	beq main


;rot13:
	cmp #'z'+1		; $7B
	bcs @output
	cmp #'A'		; $41
	bcc @output
	cmp #'O'-1		; $4E
	bcc @add
	cmp #'Z'+1		; $5B
	bcc @sub
	cmp #'a'		; $61
	bcc @output
	cmp #'o'-1		; $6E
	bcc @add




@sub:
	sec 
	sbc #13
	bra @output
@add:
	;clc ; carry will always be clear when we get here, so save on byte 
	adc #13
@output:
	inx         ; Cycles: 2 
	jsr krn_chrout ; Cycles: 6 
	bra @loop
buf:
