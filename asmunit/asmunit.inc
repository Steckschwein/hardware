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

.ifndef __ASSERTION_INC
.define	__ASSERTION_INC "__ASSERTION_INC"
.setcpu "65c02"

.define _FLAG_C0 "C=0"
.define _FLAG_C1 "C=1"
.define _FLAG_Z0 "Z=0"
.define _FLAG_Z1 "Z=1"
.define _FLAG_D0 "D=0"
.define _FLAG_D1 "D=1"
.define _FLAG_N0 "N=0"
.define _FLAG_N1 "N=1"

.define	_EXPECT_MAX_LENGTH 255

.define _FORMAT_STRING 1<<7 	; bit 7 set output string, number otherwise

.define _MODE_ASSERT_EQ 0		; 
.define _MODE_ASSERT_LEQ 1<<0 ; assert input with less or equal (<=) the expectation
.define _MODE_FAIL 1<<1
.define _MODE_TESTNAME 1<<2


_tst_ptr=$0
_tst_inp_ptr=$2

asmunit_addr_instrument = $0202

.macro cmp16 address, _16Bit
	.local @l_exit
	lda address+0
	cmp #<_16Bit
	bne @l_exit
	lda address+1
	cmp #>_16Bit
@l_exit:
.endmacro

.macro cmp32 address, _32Bit
	.local @l_exit
	cmp16 address+0, (_32Bit & $ffff)
	bne @l_exit
	cmp16 address+2, (_32Bit>>16)
@l_exit:
.endmacro

.macro set16 address, _16bit
	lda #<_16bit
	sta address+0
	lda #>_16bit
	sta address+1
.endmacro

.macro set32 address, _32Bit
	set16 address+0, (_32Bit & $ffff)
	set16 address+2, (_32Bit>>16)
.endmacro

.macro _message label, mode
	.import asmunit_assert
	.local @labelAddress
	.assert .strlen(label) <= _EXPECT_MAX_LENGTH, error, "Expectation argument exceeds limit!"
	jsr asmunit_assert
	.byte mode | _FORMAT_STRING
	.word @labelAddress
	.byte .strlen(label)
@labelAddress: .byte label
.endmacro

.macro test_begin label
	test_name label
.endmacro

.macro test_end
	brk
.endmacro

.macro test_name label
	test label
.endmacro

.macro test label
	_message .concat("[", label, "]"), _MODE_TESTNAME
.endmacro

.macro fail message
	_message message, _MODE_FAIL
.endmacro

.macro assertX expect
    .import tst_xreg
	assert8 expect, tst_xreg
.endmacro

.macro assertY expect
    .import tst_yreg
	assert8 expect, tst_yreg
.endmacro

.macro assertA expect
    .import tst_acc
	assert8 expect, tst_acc
.endmacro

.macro assertCPU expect
    .import tst_status
	assert8 expect, tst_status
.endmacro

.macro assert8 expect8, address
	.import asmunit_assert
	jsr asmunit_assert
	.byte _MODE_ASSERT_EQ
	.word address
	.byte 1
	.byte expect8
.endmacro

.macro assert16 expect16, address
	.import asmunit_assert
	jsr asmunit_assert
	.byte _MODE_ASSERT_EQ
	.word address
	.byte 2
	.word expect16
.endmacro

.macro assert32 expect32, address
	.import asmunit_assert
	jsr asmunit_assert
	.byte _MODE_ASSERT_EQ
	.word address
	.byte 4
	.dword expect32
.endmacro

.macro asmunit_assertFlag labelAddress, labelSymbol
	.import asmunit_assert
	jsr asmunit_assert
	.byte _MODE_ASSERT_EQ | _FORMAT_STRING
	.word labelAddress
	.byte .strlen(labelSymbol)
	.byte labelSymbol
.endmacro

.macro _pass
	assert8 1, *+2	; always true... cuz of the .byte 1 in the assert8 macro - FTW!
.endmacro

;
; assertD 0 => expect decimal mode not set
; assertD 1 => expect decimal mode is set
;
.macro assertD expect
	fail "TODO not implemented yet!!!"
	.assert expect = 0 || expect = 1, error, "Invalid expect, must be 0 or 1!"
	.if expect
		.import asmunit_l_flag_d0
		 asmunit_assertFlag asmunit_l_flag_d0, _FLAG_D1 ; force a fail here
	.else
		.import asmunit_l_flag_d1
		 asmunit_assertFlag asmunit_l_flag_d1, _FLAG_D0	
	.endif
;		bra :++
;:		_pass
:
.endmacro

.macro assertCarry expect
	assertC expect
.endmacro

;
; assertCarry 0 => expect carry cleared
; assertCarry 1 => expect carry set
;
.macro assertC expect
	.assert expect = 0 || expect = 1, error, "Invalid expect, must be 0 or 1!"
	.if expect
		bcs :+
		.import asmunit_l_flag_c0
		asmunit_assertFlag asmunit_l_flag_c0, _FLAG_C1 ; force a fail by compare inverse
	.else
		bcc :+
		.import asmunit_l_flag_c1
		asmunit_assertFlag asmunit_l_flag_c1, _FLAG_C0 ; force a fail by compare inverse
	.endif
;	bra :++
;:	_pass
:
.endmacro

.macro assertZero expect
	assertZ expect
.endmacro

;
; assertZero 0 => expect zero cleared
; assertZero 1 => expect zero set
;
.macro assertZ expect
	.assert expect = 0 || expect = 1, error, "Invalid expect, must be 0 or 1!"
	.if expect
		beq :+
		.import asmunit_l_flag_z0
		 asmunit_assertFlag asmunit_l_flag_z0, _FLAG_Z1 ; force a fail by compare inverse
	.else
		bne :+
		.import asmunit_l_flag_z1
		 asmunit_assertFlag asmunit_l_flag_z1, _FLAG_Z0	; force a fail by compare inverse
	.endif
;		bra :++
;:		_pass
:
.endmacro

.macro assertString expect, address
	.assert .strlen(expect) <= _EXPECT_MAX_LENGTH, error, "Expectation argument exceeds limit!"
	.import asmunit_assert
	jsr asmunit_assert
	.byte _MODE_ASSERT_EQ | _FORMAT_STRING
	.word address
	.byte .strlen(expect)
	.byte expect
.endmacro

.macro assertOut expect
	.assert .strlen(expect) <= _EXPECT_MAX_LENGTH, error, "Expectation argument exceeds limit of test output buffer!"
	
	.import asmunit_assert
	.import asmunit_char_out_buffer
	.import asmunit_char_out_ix
	
	stz asmunit_char_out_ix		; reset asmunit_char_out_buffer	before test - TODO FIXME maybe a dedicated macro?!?
	jsr asmunit_assert
	.byte _MODE_ASSERT_EQ | _FORMAT_STRING
	.word asmunit_char_out_buffer
	.byte .strlen(expect)
	.byte expect
.endmacro

;
; functional testing 
;
.macro resetCycles
	stz asmunit_addr_instrument	; write a #1 to <asmunit_addr_instrument>, it's hooked by the py65 memory observer and will update the internal cycle counter to the current cycle counter
.endmacro

.macro assertCycles cycles
	.import asmunit_assert
	lda asmunit_addr_instrument	; write a #0 will result in write the current cycle counter to memory we can assert afterwards - the cycle counter is the difference from current - last one
	jsr asmunit_assert
	.byte _MODE_ASSERT_LEQ			; compare cycles less or equal
	.word asmunit_addr_instrument+1 ; addr of cycle counter
	.byte 4
	; cycles are stored in big endian, since we want to compare from MSB down to LSB to achieve "measured cycles <= expected cycles" 
	.byte >.HIWORD(cycles)
	.byte <.HIWORD(cycles)
	.byte >.LOWORD(cycles)
	.byte <.LOWORD(cycles)
	
.endmacro

.endif