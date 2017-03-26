.include "../steckos/kernel/kernel.inc"
.include "../steckos/kernel/kernel_jumptable.inc"
.include "../steckos/asminc/common.inc"

exp     = $00
base    = $02
prod	= $04


	lda #3
	sta exp
	lda #4
	sta base
	stz prod

loop:
	jsr print_row

	lda exp
	ror
	bcc @even
	; exp is odd, add base to product
	lda base
	clc
	adc prod
	sta prod
@even:

	asl base
	lsr exp

	lda exp
	bne loop	

	lda #$0a
	jsr krn_chrout

	lda prod
	jsr krn_hexout

end:	jmp end
print_row:
	lda #$0a
	jsr krn_chrout

	lda exp
	jsr krn_hexout

	lda #' '
	jsr krn_chrout

	lda base
	jsr krn_hexout
	
	rts
