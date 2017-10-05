.ifndef __DEBUG_INC
.define	__DEBUG_INC "__DEBUG_INC"

.import _debugout, _debugout8, _debugout16, _debugout32
.import _debugout32p
.import _debugdump

dbg_acc				= $02f9 ; basic uses $0290 - $02f8
dbg_xreg			= $02fa
dbg_yreg			= $02fb
dbg_status			= $02fc
dbg_bytes			= $02fd
dbg_savept			= $02fe

.macro debug msg
.ifdef DEBUG
		jsr	_debugout
		.asciiz msg
.endif
.endmacro

.macro debug8 msg, ptr
.ifdef DEBUG
		jsr	_debugout8
		.word ptr
		.asciiz msg
.endif
.endmacro

.macro debug16 msg, ptr
.ifdef DEBUG
		jsr	_debugout16
		.word ptr
		.asciiz msg
.endif
.endmacro

.macro debug32p msg, ptr
.ifdef DEBUG
		jsr	_debugout32p
		.word ptr
		.asciiz msg
.endif
.endmacro

.macro debug32 msg, addr
.ifdef DEBUG
		jsr	_debugout32
		.word addr
		.asciiz msg
.endif
.endmacro

.macro debugdump msg, addr, n
	.if .defined(debug_enabled)
			jsrss _debugdump
			.word addr
			.asciiz msg
	.endif
.endmacro

.endif