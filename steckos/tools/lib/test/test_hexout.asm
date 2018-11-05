.include "asmunit.inc" 	; unit test api

.import hexout		; uut
	
.code

	test "hexout"

	lda	#$7e
	jsr	hexout
	
	assertOut "7E"	; assert outpuz
	assertA $7e		; assert A is not destroyed

	lda	#$e7
	jsr	hexout
	
	assertOut "E7"	;
	assertA $e7		;
	
	lda	#$9f
	
	jsr	hexout	
	
	assertOut "9F"
	assertA $9f	
	
	brk
	
.segment "ASMUNIT"