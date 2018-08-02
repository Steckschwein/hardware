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

.define	_CHAR_OUT_BUFFER_LENGTH 32
.define	_TYPE_STRING $80


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
	jsr _assert
	.word address
	.byte 1
	.byte expect8
.endmacro

.macro assert16 expect16, address
	jsr _assert
	.word address
	.byte 2
	.word expect16
.endmacro

.macro assert32 expect32, address
	jsr _assert
	.word address
	.byte 4
	.dword expect32
.endmacro

.macro _assertFlag labelAddress, labelSymbol
		jsr _assert
		.word labelAddress
		.byte _TYPE_STRING | .strlen(labelSymbol)
		.byte labelSymbol
.endmacro

.macro _pass
	assert8 1, *+2
.endmacro

;
; assertCarry 0 => expect carry cleared
; assertCarry 1 => expect carry set
;
.macro assertCarry expect
	.assert expect = 0 || expect = 1, error, "Invalid expect, must be 0 or 1!"
	.if expect
		bcs :+
		_assertFlag _l_flag_c0, _FLAG_C1
		bra :++
:		_pass
	.else
		bcc :+
		_assertFlag _l_flag_c1, _FLAG_C0
		bra :++
:		_pass
	.endif
:
.endmacro

;
; assertZero 0 => expect zero cleared
; assertZero 1 => expect zero set
;
.macro assertZero expect
	.assert expect = 0 || expect = 1, error, "Invalid expect, must be 0 or 1!"
	.if expect
		bne :+
		_assertFlag _l_flag_z0, _FLAG_Z1
		bra :++
:		_pass
	.else
		beq :+
		_assertFlag _l_flag_z1, _FLAG_Z0
		bra :++
:		_pass
	.endif
:
.endmacro

.macro assertString expect, address
	jsr _assert
	.word address
	.byte _TYPE_STRING | .strlen(expect)
	.byte expect
.endmacro

.macro assertOut expect
	.assert .strlen(expect) <= _CHAR_OUT_BUFFER_LENGTH, error, "Expectation argument exceeds size of test output buffer!"
	stz _char_out_ptr					; reset char_out_buffer	before test - TODO FIXME maybe a dedicated macro?!?
	jsr _assert
	.word char_out_buffer
	.byte _TYPE_STRING | .strlen(expect)
	.byte expect
.endmacro

.endif