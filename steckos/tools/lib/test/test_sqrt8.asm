.import sqrt8					; uut
.include "assertion.inc" 	; unit test api

.code
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

	.include "asmunit.asm"
