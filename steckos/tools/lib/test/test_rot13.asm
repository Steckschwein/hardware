.include "asmunit.inc" 	; unit test api

.import rot13					; uut

.code

	test "rot13"
	
    ldx #$00
    ldy #$00
	lda	#'A'
	jsr	rot13

	assertA 'N'		
	assertX $00		; assert X,Y is not destroyed
	assertY $00

	lda	#'X'
	jsr	rot13

	assertA 'K'		

	lda	#'0'
	jsr	rot13

	assertA '0'		

	lda	#'9'
	jsr	rot13

	assertA '9'
	brk
	
.segment "ASMUNIT"