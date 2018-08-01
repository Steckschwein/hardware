	.import bin2dual					; uut
	.include "assertion.inc" 	; test api

	; required to run with steckos only
	.include "kernel_jumptable.inc"

.code
	lda	#$ff
	ldx #$00
	jsr	bin2dual

	assertOut "11111111"	; assert outpuz
	assertA $ff		; assert A is not destroyed
	assertX $00

	lda	#$f0
	ldx #$00
	jsr	bin2dual

	assertOut "11110000"	; assert outpuz
	assertA $f0		; assert A is not destroyed
	assertX $00

	lda	#$0f
	ldx #$00
	jsr	bin2dual

	assertOut "00001111"	; assert outpuz
	assertA $0f		; assert A is not destroyed
	assertX $00

	lda	#$55
	ldx #$00
	jsr	bin2dual

	assertOut "01010101"	; assert outpuz
	assertA $55		; assert A is not destroyed
	assertX $00

	lda	#$aa
	ldx #$00
	jsr	bin2dual

	assertOut "10101010"	; assert outpuz
	assertA $aa		; assert A is not destroyed
	assertX $00


	rts

	.include "asmunit.asm"
