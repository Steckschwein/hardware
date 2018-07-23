.setcpu "65c02"	
_char_out_ptr: .res 1,0
char_out_buffer: .res 32,0

.export char_out=_char_out

;char_out=_char_out
;_char_out_ptr: .rs 1
;char_out_buffer: .rs 32

tst_acc			= $0100	; we use the lower part of the stack as temp space assuming the stack is almost not complety exhausted :/
tst_xreg			= $0101
tst_yreg			= $0102
tst_status		= $0103
tst_save_ptr	= $0104 ; to save and restore the _tst_ptr
tst_return_ptr	= $0106 ; to save and restore the _tst_exp_ptr and to build the return vector
tst_bytes		= $0108

_tst_ptr=$0
_tst_inp_ptr=$2			; 

_char_out:
	phx
	ldx _char_out_ptr
	sta char_out_buffer, x
	inc _char_out_ptr
	plx
	rts

_assert:
		sta tst_acc
		stx tst_xreg
		sty tst_yreg
		php
		pla
		sta tst_status
		cld
		
		lda _tst_ptr			; save old pointer for later restor
		sta tst_save_ptr
		lda _tst_ptr+1
		sta tst_save_ptr+1
		
		lda _tst_inp_ptr			; save old pointer for later restor
		sta tst_return_ptr
		lda _tst_inp_ptr+1
		sta tst_return_ptr+1		
		
		pla							; Get the low part of "return" address,
		sta _tst_ptr
		pla							; Get the high part of "return" address
		sta _tst_ptr+1
		
		jsr _inc_tst_ptr			; argument 1 - adress of test input
		
		lda (_tst_ptr)				; setup test input ptr
		sta _tst_inp_ptr
		jsr _inc_tst_ptr
		lda (_tst_ptr)				
		sta _tst_inp_ptr+1
		
		jsr _inc_tst_ptr			; argument 2 - length of expect argument		
		lda	(_tst_ptr)
		sta tst_bytes

		jsr _inc_tst_ptr			; argument 3 - the expectation value
		lda _tst_ptr
		pha
		lda _tst_ptr+1
		pha							; save ptr of argument 3 back to stack for fialure handling

		ldy #0
_l_assert:
		lda (_tst_inp_ptr),y		; get next value
		cmp	(_tst_ptr)			; and assert
		bne	_assert_fail
		jsr _inc_tst_ptr			
		iny
		cpy tst_bytes
		bne _l_assert				; back around	
			
		;TEST PASS
		pla
		pla		
		ldy #0 ;<(_l_pass-_l_messages)
		jsr _print
		bra _l_end
		
		;TEST FAIL
_assert_fail:
		jsr _inc_tst_ptr			
		iny							; adjust the pointer, consume the arguments
		cpy tst_bytes
		bne _assert_fail		
		
		ldy #5 ;<(_l_fail-_l_messages)
		jsr _print
		
		ldy #0
_fail_l1:						; was ...
		lda (_tst_inp_ptr),y
		jsr _test_out
		iny
		cpy tst_bytes
		bne _fail_l1
		
		ldy #16 ;<(_l_fail_was-_l_messages)
		jsr _print		

		pla
		sta _tst_inp_ptr+1
		pla
		sta _tst_inp_ptr
		ldy #0
_fail_l2:						; expected ...
		lda (_tst_inp_ptr),y
		jsr _test_out
		iny 
		cpy tst_bytes
		bne _fail_l2
		
_l_end:
		lda #$0a
		jsr _test_out
		lda #$0d
		jsr _test_out
		
		lda tst_return_ptr		; restore old value at _tst_inp_ptr
		sta _tst_inp_ptr
		lda tst_return_ptr+1
		sta _tst_inp_ptr+1

		lda	_tst_ptr			; _tst_ptr points to instruction at the end of assert parameter, adjust return vector
		sta tst_return_ptr
		lda	_tst_ptr+1
		sta tst_return_ptr+1

		lda tst_save_ptr		; restore old value at _tst_ptr
		sta _tst_ptr
		lda tst_save_ptr+1
		sta _tst_ptr+1
		
		lda tst_status
		pha
		lda	tst_acc
		ldx	tst_xreg
		ldy	tst_yreg
		plp
		
		jmp (tst_return_ptr)           ; return to byte following final NULL

_inc_tst_ptr:
		inc     _tst_ptr      	; update the pointer
		bne     _l_exit         	; if not, we're pointing to next value
		inc     _tst_ptr+1		; account for page crossing
_l_exit:
		rts
_print:
		lda _l_messages,y
		tax
_l_out:	beq _l_exit
		iny
		lda _l_messages,y
		jsr _test_out
		dex
		bra _l_out		
_test_out:
		jsr test_char_out
		rts
		
_l_messages:
_l_pass:	 		.byte 4,  "PASS"
_l_fail: 		.byte 10, "FAIL, was "
_l_fail_was:	.byte 10,	" expected "
