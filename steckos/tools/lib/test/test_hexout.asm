	; uut
	.import hexout
	; test api
	.include "assertion.inc" 

.code
	
	lda	#$7e
	jsr	hexout

	assertOut "7E"	; assert outpuz
	assertA $7e		; assert A is not destroyed
		
	rts
	
	.include "asmunit.asm" 