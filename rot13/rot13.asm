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

	ldy #$00
	bit #$20	; capital letter? keep in mind
	bne @l1
	iny
@l1:
	
	ora #$20	; make lowercase
	
	cmp #'a'-1	; lower than a or greater than z ? just output
	bcc @output
	cmp #'z'+1
	bcs @output
	

;	clc ; no need to clear carry explicitly here
	adc #13		; shift character by 13 
	cmp #'z'+1	; wraparound?
	bcc @output
;	sec ; no need to set carry explicitly here
	sbc #26		; yes, substract 26
	
@output:
	cpy #$00	; was it uppercase?
	beq @l2
	and #$df	; yes, make encoded character uppercase
@l2:
	inx
	jsr krn_chrout
	bra @loop
buf:
