.import rot13					; uut
.include "assertion.inc" 	; unit test api

asmunit_char_out=$f001		; py65mon output

.code
    ldx #$00
    ldy #$00
	lda	#'A'
	jsr	rot13

	assertA 'N'		; assert A is not destroyed
	assertX $00
	assertY $00

	rts

	.include "asmunit.asm"
