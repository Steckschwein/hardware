.ifndef __DEBUG_INC
.define	__DEBUG_INC "__DEBUG_INC"

.import _debugout, _debugout8, _debugout16, _debugout32		

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

.macro debug32 msg, ptr
.ifdef DEBUG
		jsr	_debugout32
		.word ptr
		.asciiz msg
.endif
.endmacro

.endif