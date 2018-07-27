.import hexout					; uut
.include "assertion.inc" 	; unit test api
	
asmunit_char_out=$f001		; py65mon output

.code	
	lda	#$7e
	jsr	hexout
	
	assertOut "7E"	; assert outpuz
	assertA $7e		; assert A is not destroyed

	lda	#$e7
	jsr	hexout
	
	assertOut "E7"	; assert outpuz
	assertA $e7		; assert A is not destroyed
	
	lda	#$9f
	jsr	hexout
	
	assertOut "9F"	
	assertA $9f	

	rts
	
	.include "asmunit.asm" 