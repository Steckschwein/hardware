.ifndef __ASSERTION_INC
.define	__ASSERTION_INC "__ASSERTION_INC"
.setcpu "65c02"

_CHAR_OUT_BUFFER_LENGTH=32

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

.macro assertOut expect_string
	.assert .strlen(expect_string) <= _CHAR_OUT_BUFFER_LENGTH, error, "Expectation argument exceeds size of test output buffer!"
	stz _char_out_ptr					; reset char_out_buffer	before test - TODO FIXME maybe a dedicated macro?!?
	jsr _assert
	.word char_out_buffer
	.byte .strlen(expect_string)
	.byte expect_string
.endmacro

.endif