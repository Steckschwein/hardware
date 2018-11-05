.include "asmunit.inc" 	; unit test api
	
.import bin2dual					; uut

.code

	test "bin2dual"
	
	lda #$ff
	ldx #$00
	jsr bin2dual

	assertOut "11111111"	; assert outpuz
	assertX $00
	assertA $ff		; assert A is not destroyed

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

	brk

.segment "ASMUNIT"