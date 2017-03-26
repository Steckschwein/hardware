.include "../steckos/kernel/kernel.inc"
.include "../steckos/kernel/kernel_jumptable.inc"
.include "../steckos/asminc/common.inc"

.macro asl16 op
	asl op
	rol op+1
.endmacro

.macro lsr16 op
	lsr op+1
	ror op
.endmacro

exp     = $00
base    = $02
prod	= $04

op1	= 7569
op2	= 5


	lda #<op1
	sta exp
	lda #>op1
	sta exp+1

	lda #<op2
	sta base
	lda #>op2
	sta base+1

	stz prod
	stz prod+1

loop:
	jsr print_row

	;clc
	;lda exp+1
	;ror
	lda exp
	;ror
	lsr

	bcc @even
	; exp is odd, add base to product
	lda base
	clc
	adc prod
	sta prod

	lda base+1
	adc prod+1
	sta prod+1

@even:

	asl16 base
	lsr16 exp

	lda exp+1
	bne loop	
	lda exp
	bne loop	

	lda #$0a
	jsr krn_chrout

	lda prod+1
	jsr krn_hexout
	lda prod
	jsr krn_hexout

end:	jmp krn_upload

print_row:
	lda #$0a
	jsr krn_chrout

	lda exp+1
	jsr krn_hexout
	lda exp
	jsr krn_hexout

	lda #' '
	jsr krn_chrout
	lda #'*'
	jsr krn_chrout
	lda #' '
	jsr krn_chrout

	lda base+1
	jsr krn_hexout
	lda base
	jsr krn_hexout
	
	rts
