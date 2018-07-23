; uut
 .org  $1000
 ;.export char_out=$f001

.include "../../../../asmunit/assertion.inc" 

.code
	;.import hexout
	lda	#$7e
	jsr	hexout

	assertOut "7E"
	assertA $7e		; test unchanged
	
	jsr _assert
	.word char_out_buffer	; test input
	.byte 2
	.byte "7E"				; expect

	jsr _assert
	.word tst_acc			; test input
	.byte 1
	.byte $7e				; expect
	
	nop
	nop	
	rts
	
 .include "../../../../asmunit/asmunit.asm" 
 .include "../hexout.asm"