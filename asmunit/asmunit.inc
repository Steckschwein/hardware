.ifndef __ASMUNIT_INC
.define	__ASMUNIT_INC "__ASMUNIT_INC"

tst_acc				= $0100
tst_xreg			= $0101
tst_yreg			= $0102
tst_status			= $0103
tst_savept			= $0104
tst_return			= $0106
tst_bytes			= $0108

_tst_addr_ptr=$0
_tst_ptr=$2

.macro assertX expect
	jsr _assert_xreg
	.word tst_xreg
	.byte expect
.endmacro

.macro assertY expect
	jsr _assert_yreg
	.word tst_yreg
	.byte expect
.endmacro

.macro assertA expect
	jsr _assert_acc
	.word tst_acc
	.byte expect
.endmacro

.macro assert8 msg, expect8, address
	jsr _assert8
	.word address
	.byte expect8
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

_assert_enter:
		sta tst_acc
		stx tst_xreg
		sty tst_yreg
		php
		pla
		sta tst_status
		cld
		
		lda 	_tst_addr_ptr
		sta 	tst_savept
		lda 	_tst_addr_ptr+1
		sta 	tst_savept+1
		
		rts

_assert_acc:
		jsr _assert_enter
		bra _assert_1
		
_assert16:
		jsr _assert_enter
		ldx #2
		bra	_assert
_assert8:
		jsr _assert_enter
_assert_1:
		lda #1
_assert:
		sta 	tst_bytes
		pla							; Get the low part of "return" address
		sta		_tst_ptr		
		pla							; Get the high part of "return" address
		sta		_tst_ptr+1

		jsr		_inc_tst_ptr		; Note: actually we're pointing one short

		lda 	(_tst_ptr)			; +2, address argument
		sta		_tst_addr_ptr
		jsr		_inc_tst_ptr
		lda 	(_tst_ptr)
		sta		_tst_addr_ptr+1		; address is now setup in _tst_addr_ptr
		jsr		_inc_tst_ptr
		
		ldy 	tst_bytes
@l_assert:
		lda     (_tst_addr_ptr)	,y	; Get the next value
		cmp		(_tst_ptr)		,y	; and assert
		bne		@_assert_fail
		dey
		bne 	@l_assert			; back around		
@_assert_end:
		lda		_tst_addr_ptr		; _tst_addr_ptr points to instruction after assert parameter, adjust ret vector
		sta 	tst_return
		lda		_tst_addr_ptr+1
		sta 	tst_return+1

		lda 	tst_savept				; restore _tst_addr_ptr
		sta 	_tst_addr_ptr
		lda 	tst_savept+1
		sta 	_tst_addr_ptr+1
		
		lda 	tst_status
		pha
		lda		tst_acc
		ldx		tst_xreg
		ldy		tst_yreg
		plp
		
		jmp     (tst_return)           ; return to byte following final NULL
.endif

_inc_tst_ptr:
		inc     _tst_ptr      	; update the pointer
		bne     @l_exit         	; if not, we're pointing to next value
		inc     _tst_ptr+1		; account for page crossing
@l_exit:
		rts