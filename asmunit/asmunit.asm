; MIT License
;
; Copyright (c) 2018 Thomas Woinke, Marko Lauke, www.steckschwein.de
;
; Permission is hereby granted, free of charge, to any person obtaining a copy
; of this software and associated documentation files (the "Software"), to deal
; in the Software without restriction, including without limitation the rights
; to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
; copies of the Software, and to permit persons to whom the Software is
; furnished to do so, subject to the following conditions:
;
; The above copyright notice and this permission notice shall be included in all
; copies or substantial portions of the Software.
;
; THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
; IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
; FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
; AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
; LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
; OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
; SOFTWARE. 

.include "asmunit.inc"

.export asmunit_char_out_ix
.export asmunit_char_out_buffer

.export char_out=_char_out
.export asmunit_assert
.export asmunit_chrout

.export asmunit_l_flag_c0
.export asmunit_l_flag_c1
.export asmunit_l_flag_z0
.export asmunit_l_flag_z1

.segment "ASMUNIT"

asmunit_char_out_buffer:	.res _EXPECT_MAX_LENGTH,0
asmunit_char_out_ix: 		.res 1,0

_char_out:
		phx
		ldx asmunit_char_out_ix
		sta asmunit_char_out_buffer, x
		inc asmunit_char_out_ix
		plx
		rts

asmunit_assert:
		sta tst_acc
		stx tst_xreg
		sty tst_yreg
		php
		pla
		sta tst_status
		cld
		
		lda _tst_ptr				; save old pointer for later restor
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
		
		jsr _inc_tst_ptr			; argument 1 - the assertion mode
		lda (_tst_ptr)
		tax							; save the mode in X
		
		jsr _inc_tst_ptr			; argument 2 - address of test input		
		lda (_tst_ptr)				; setup test input ptr
		sta _tst_inp_ptr
		jsr _inc_tst_ptr
		lda (_tst_ptr)				
		sta _tst_inp_ptr+1
		
		jsr _inc_tst_ptr			; argument 3 - length of expect argument		
		lda (_tst_ptr)
		sta tst_bytes
		
		jsr _inc_tst_ptr			; argument 4 - the expectation value
		lda _tst_ptr
		pha
		lda _tst_ptr+1
		pha							; save ptr of argument 4 back to stack for failure handling

		ldy #0
		txa
		bit #_MODE_ASSERT_LEQ
		bne @_l_assert_leq
@_l_assert:
		lda (_tst_inp_ptr),y
		cmp (_tst_ptr)
		bne _assert_fail
		jsr _inc_tst_ptr
		iny
		cpy tst_bytes
		bne @_l_assert				; back around	
		bra @_l_assert_end
@_l_assert_leq:
		lda (_tst_inp_ptr),y
		cmp (_tst_ptr)
		bcc l_pass					; < ; can already exit here
		bne _assert_fail			; =
		jsr _inc_tst_ptr
		iny
		cpy tst_bytes
		bne @_l_assert_leq							; back around			

@_l_assert_end:		
		txa
		bit #_MODE_TESTNAME	; assertion was ok if we end up here
		bne l_test_name
		bit #_MODE_FAIL
		bne _assert_fail_msg
l_pass_msg:												; proceed to "PASS"
;		ldy #<(_l_msg_pass-_l_messages)
;		jsr _print		
l_pass_end:
		pla
		pla

l_return:
		lda tst_return_ptr		; restore old value at _tst_inp_ptr
		sta _tst_inp_ptr
		lda tst_return_ptr+1
		sta _tst_inp_ptr+1

		lda _tst_ptr			; _tst_ptr points to instruction at the end of assert parameter, adjust return vector
		sta tst_return_ptr
		lda _tst_ptr+1
		sta tst_return_ptr+1

		lda tst_save_ptr		; restore old value at _tst_ptr
		sta _tst_ptr
		lda tst_save_ptr+1
		sta _tst_ptr+1
		
		lda tst_status
		pha
		lda tst_acc
		ldx tst_xreg
		ldy tst_yreg
		plp
		jmp (tst_return_ptr)           ; return to byte following final NULL

l_test_name:
		lda #$0a
		jsr asmunit_chrout
		jsr _out_ptr
		bra l_pass_end
		
l_pass:
		jsr _l_adjust_ptr
		bra l_pass_msg
		
_l_adjust_ptr:
		jsr _inc_tst_ptr
		iny									; adjust the pointer, consume the arguments
		cpy tst_bytes
		bne _l_adjust_ptr
		rts
		
_assert_fail_msg:
		ldy #<(_l_msg_fail-_l_messages)	; ouput "FAIL, was "
		bra _assert_fail_expect
		;assertion fail
_assert_fail:
		jsr _l_adjust_ptr
		
		ldy #<(_l_msg_fail-_l_messages)	; ouput "FAIL, was "
		jsr _print
		jsr _out_ptr							; argument
		
		ldy #<(_l_msg_fail_exp-_l_messages)
_assert_fail_expect:
		jsr _print								; ouput " expected "
		pla										; restore ptr to argument 3 (expected) from above
		sta _tst_inp_ptr+1
		pla
		sta _tst_inp_ptr
		jsr _out_ptr							; expected ...
		
		bra l_return		
		brk										; fail immediately, we will end up in monitor

_out_ptr:
		phx
		ldy #0
		txa
		and #_FORMAT_STRING
		bne _out_ptr_string
		lda #'$'									; number in hex with preceeding $
		jsr asmunit_chrout
		ldx #0									; output is number
_out_ptr_loop:									; TODO big endian, for better readability
		lda (_tst_inp_ptr),y
		jsr _call_out
		iny
		cpy tst_bytes
		bne _out_ptr_loop
		plx
		rts
_out_ptr_string:
		ldx #2									; output is string
		bra _out_ptr_loop
		
_call_out:
		jmp (_out,x)
_out:
		.word _hexout
		.word asmunit_chrout

_inc_tst_ptr:
		inc _tst_ptr      		; update the pointer
		bne _l_exit         		; if not, we're pointing to next value
		inc _tst_ptr+1				; account for page crossing
_l_exit:
		rts
_print:								; print length prefixed string
		phx
		lda _l_messages,y
		tax
_l_out:
		beq :+
		iny
		lda _l_messages,y
		jsr asmunit_chrout
		dex
		bra _l_out
:		plx
		rts
_hexout:
		pha
		lsr
		lsr
		lsr
		lsr
		jsr _hexdigit
		pla
_hexdigit:
		and #$0f      	;mask lsd for hex print
		ora #'0'			;add "0"
		cmp #'9'+1		;is it a decimal digit?
		bcc asmunit_chrout	;yes! output it
		adc #$26			;add offset for letter a-f
		bra asmunit_chrout
		
asmunit_chrout:
		sta asmunit_char_out
		rts
				
_l_messages:
_l_msg_pass:	 		.byte _l_msg_fail-_l_msg_pass-1,	$0a,"PASS"
_l_msg_fail: 			.byte _l_msg_fail_exp-_l_msg_fail-1, $0a, "FAIL - "
_l_msg_fail_exp:		.byte asmunit_l_flag_c0-_l_msg_fail_exp-1, " found, but expected "
asmunit_l_flag_c0:	.byte _FLAG_C0
asmunit_l_flag_c1:	.byte _FLAG_C1
asmunit_l_flag_z0:	.byte _FLAG_Z0
asmunit_l_flag_z1:	.byte _FLAG_Z1
asmunit_l_flag_d0:	.byte _FLAG_D0
asmunit_l_flag_d1:	.byte _FLAG_D1