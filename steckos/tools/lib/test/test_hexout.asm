; uut
 .org  $1000
 ;.export char_out=$f001

tst_acc			= $0100	; we use the lower part of the stack as temp space assuming the stack is almost not complety exhausted :/
tst_xreg		= $0101
tst_yreg		= $0102
tst_status		= $0103
tst_save_ptr	= $0104 ; to save and restore the _tst_ptr
tst_return_ptr	= $0106 ; to save and restore the _tst_exp_ptr and to build the return vector
tst_bytes		= $0108

_tst_ptr=$0
_tst_inp_ptr=$2			; 


.code
	lda #01
	sta $0
	lda #02
	sta $1
	lda #02
	sta $2
	lda #03
	sta $3
	
	;.import hexout
	lda	#$7e
	jsr	hexout

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
