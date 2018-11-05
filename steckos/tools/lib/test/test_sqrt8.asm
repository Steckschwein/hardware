.include "asmunit.inc" 	; unit test api

.import sqrt8					; uut

.code

	test "sqrt8"
	
	ldx #$00
	lda	#25
	sta $20
	jsr	sqrt8

	assert8 5, $20
	assertX $00

	lda	#0
	sta $20
	jsr	sqrt8

	assert8 1, $20

.segment "ASMUNIT"