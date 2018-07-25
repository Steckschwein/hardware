	.import hexout					; uut
	.include "assertion.inc" 	; test api

	; required to run with steckos only
	.include "kernel_jumptable.inc"
	test_char_out=$f001;krn_chrout	 

;.segment "EXEHDR" 
;	.byte   1

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