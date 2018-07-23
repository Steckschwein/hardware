.ifndef __ASSERTION_INC
.define	__ASSERTION_INC "__ASSERTION_INC"
.setcpu "65c02"
 
tst_acc			= $0100
tst_xreg			= $0101
tst_yreg			= $0102
tst_status		= $0103
tst_savept		= $0104
tst_return		= $0106
tst_bytes		= $0108

_tst_addr_ptr=$0
_tst_ptr=$2

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
	jsr _assert
	.word char_out_buffer
	.byte .sizeof(expect_string)
	.byte expect_string
.endmacro

.endif