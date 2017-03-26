.include "../steckos/kernel/kernel.inc"
.include "../steckos/kernel/kernel_jumptable.inc"
.include "../steckos/asminc/common.inc"

.macro asl16 op
	asl op   ; 5
	rol op+1 ; 5
.endmacro

.macro lsr16 op
	lsr op+1 ; 5
	ror op   ; 5
.endmacro

exp     = $00
base    = $02
prod	= $04

op2	= 7569
op1	= 5


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
.ifdef OUTPUT
	jsr print_row
.endif

	lda exp ; 3 ; load low byte from exp and shift 1 place to the right
	lsr	; 2 ;to put bit0 into the carry flag

	bcc @even ; 2/3
	; exp is odd, add base to product
	lda base ; 3
	clc	 ; 2
	adc prod ; 3
	sta prod ; 3

	lda base+1 ; 3
	adc prod+1 ; 3
	sta prod+1 ; 3

@even:

	asl16 base ; 10
	lsr16 exp  ; 10

	lda exp+1  ; 3
	bne loop   ; 2/3	
	lda exp	   ; 3
	bne loop   ; 2/3	
	; ~60 cycles 


	lda #$0a   
	jsr krn_chrout

	lda prod+1
	jsr krn_hexout
	lda prod
	jsr krn_hexout

end:	jmp krn_upload

.ifdef OUTPUT
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
.endif
