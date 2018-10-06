; MIT License
;
; Copyright (c) 2018 Thomas Woinke, Marko Lauke, www.steckschein.de
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

.ifndef __ASSERTION_INC
.define	__ASSERTION_INC "__ASSERTION_INC"
.setcpu "65c02"

.define _FLAG_C0 "C=0"
.define _FLAG_C1 "C=1"
.define _FLAG_Z0 "Z=0"
.define _FLAG_Z1 "Z=1"

.define	_EXPECT_MAX_LENGTH 32
.define	_OUTPUT_STRING 1<<7
.define	_OUTPUT_MODE	1<<6


tst_acc			= $0100	; we use the lower part of the stack as temp space assuming the stack is almost not complety exhausted... hopefully :P
tst_xreg			= $0101
tst_yreg			= $0102
tst_status		= $0103
tst_save_ptr	= $0104 ; to save and restore the _tst_ptr
tst_return_ptr	= $0106 ; to save and restore the _tst_exp_ptr and to build the return vector
tst_bytes		= $0108

;.import asmunit_print
;.import asmunit_assert
;.import asmunit_l_flag_c0
;.import asmunit_l_flag_c1
;.import asmunit_l_flag_z0
;.import asmunit_l_flag_z1
;.import asmunit_char_out_buffer
;.import asmunit_char_out_ptr

.macro test_name label
	.import asmunit_assert
	.local @labelAddress
	.assert .strlen(label) <= _EXPECT_MAX_LENGTH, error, "Expectation argument exceeds limit!"

	jsr  asmunit_assert
	.word @labelAddress
	.byte _OUTPUT_MODE | _OUTPUT_STRING | .strlen(label)
@labelAddress: .byte label
.endmacro

.macro assertX expect
	assert8 expect, tst_xreg
.endmacro

.macro assertY expect
	assert8 expect, tst_yreg
.endmacro

.macro assertA expect
	assert8 expect, tst_acc
.endmacro

.macro assertCPU expect
	assert8 expect, tst_status
.endmacro

.macro assert8 expect8, address
	.import asmunit_assert
	jsr  asmunit_assert
	.word address
	.byte 1
	.byte expect8
.endmacro

.macro assert16 expect16, address
	.import asmunit_assert
	jsr  asmunit_assert
	.word address
	.byte 2
	.word expect16
.endmacro

.macro assert32 expect32, address
	.import asmunit_assert
	jsr  asmunit_assert
	.word address
	.byte 4
	.dword expect32
.endmacro

.macro  asmunit_assertFlag labelAddress, labelSymbol
	.import asmunit_assert
	jsr  asmunit_assert
	.word labelAddress
	.byte _OUTPUT_STRING | .strlen(labelSymbol)
	.byte labelSymbol
.endmacro

.macro _pass
	assert8 1, *+2	; always true... FTW!
.endmacro

;
; assertCarry 0 => expect carry cleared
; assertCarry 1 => expect carry set
;
.macro assertCarry expect
	.assert expect = 0 || expect = 1, error, "Invalid expect, must be 0 or 1!"
	.if expect
		bcs :+
		.import asmunit_l_flag_c0
		 asmunit_assertFlag asmunit_l_flag_c0, _FLAG_C1
	.else
		bcc :+
		.import asmunit_l_flag_c1
		 asmunit_assertFlag asmunit_l_flag_c1, _FLAG_C0
	.endif
		bra :++
:		_pass
:
.endmacro

;
; assertZero 0 => expect zero cleared
; assertZero 1 => expect zero set
;
.macro assertZero expect
	.assert expect = 0 || expect = 1, error, "Invalid expect, must be 0 or 1!"
	.if expect
		beq :+
		.import asmunit_l_flag_z0
		 asmunit_assertFlag asmunit_l_flag_z0, _FLAG_Z1
	.else
		bne :+
		.import asmunit_l_flag_z1
		 asmunit_assertFlag asmunit_l_flag_z1, _FLAG_Z0
	.endif
		bra :++
:		_pass
:
.endmacro

.macro assertString expect, address
	.import asmunit_assert
	jsr asmunit_assert
	.word address
	.assert .strlen(expect) <= _EXPECT_MAX_LENGTH, error, "Expectation argument exceeds limit!"
	.byte _OUTPUT_STRING | .strlen(expect)
	.byte expect
.endmacro

.macro assertOut expect
	.import asmunit_assert
	.import asmunit_char_out_buffer
	.import asmunit_char_out_ptr
	
	.assert .strlen(expect) <= _EXPECT_MAX_LENGTH, error, "Expectation argument exceeds limit of test output buffer!"
	stz asmunit_char_out_ptr					; reset asmunit_char_out_buffer	before test - TODO FIXME maybe a dedicated macro?!?
	jsr asmunit_assert
	.word asmunit_char_out_buffer
	.byte _OUTPUT_STRING | .strlen(expect)
	.byte expect
.endmacro

.endif