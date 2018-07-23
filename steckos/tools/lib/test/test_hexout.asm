	.import hexout					; uut
	.include "assertion.inc" 	; test api
	
	.include "kernel_jumptable.inc"
	test_char_out=krn_chrout

.code
	
	lda	#$7e
	jsr	hexout

	assertOut "7E"	; assert outpuz
	assertA $7e		; assert A is not destroyed

	lda	#$e7
	jsr	hexout
	
	assertOut "E7"	; assert outpuz
	assertA $e7		; assert A is not destroyed
	
	rts
	
	.include "asmunit.asm" 