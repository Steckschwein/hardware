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
	jsr _assert8
	.word tst_xreg
	.byte expect
.endmacro

.macro assertY expect
	jsr _assert8
	.word tst_yreg
	.byte expect
.endmacro

.macro assertA expect
	jsr _assert8
	.word tst_acc
	.byte expect
.endmacro

.macro assert8 msg, expect8, address
	jsr _assert8
	.word address
	.byte expect8
	.asciiz msg
.endmacro

.macro assert16out msg, expect_string
	jsr _assert16
	.word char_out_buffer
	.byte expect_string
	.asciiz msg
.endmacro

.macro assert16 msg, expect16, address
	jsr _assert16
	.word address
	.word expect16
	.asciiz msg
.endmacro

.macro assert32 msg, expect32, address
	jsr _assert32
	.word address
	.dword expect32
	.asciiz msg
.endmacro

.endif