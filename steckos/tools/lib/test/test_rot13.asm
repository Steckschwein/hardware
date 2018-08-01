.import rot13					; uut
.include "assertion.inc" 	; unit test api

.code
    ldx #$00
    ldy #$00
	lda	#'A'
	jsr	rot13

	assertA 'N'		; assert A is not destroyed
	assertX $00
	assertY $00

	lda	#'X'
	jsr	rot13

	assertA 'K'		; assert A is not destroyed

	lda	#'0'
	jsr	rot13

	assertA '0'		; assert A is not destroyed

	lda	#'9'
	jsr	rot13

	assertA '9'		; assert A is not destroyed
	rts

	.include "asmunit.asm"
