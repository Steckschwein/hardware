.setcpu "65c02"
	
_char_out_ptr: .res 1,0
	char_out_buffer: .res 32,0
.export char_out=_char_out
_char_out:
	phx
	ldx _char_out_ptr
	sta char_out_buffer, x
	inc _char_out_ptr
	plx
	rts

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

@_assert_fail:
		rts

_inc_tst_ptr:
		inc     _tst_ptr      	; update the pointer
		bne     @l_exit         	; if not, we're pointing to next value
		inc     _tst_ptr+1		; account for page crossing
@l_exit:
		rts