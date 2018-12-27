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

.include "common.inc"
.include "errno.inc"
.include "fcntl.inc"	; @see ca65 fcntl.inc
.include "../kernel/kernel.inc"
.include "../kernel/kernel_jumptable.inc"

.include "appstart.inc"
.import hexout

.export char_out=krn_chrout

appstart $1000

		lda (paramptr)	; empty string?
		bne @l_cp
		lda #$99
		bra @errmsg
@l_cp:
    	lda paramptr
    	ldx paramptr+1
		ldy #O_RDONLY
    	jsr krn_open
		bne @errmsg
		stx fd1

@l0:	lda (paramptr)
		cmp #' '
		beq @l1
		inc paramptr
		bne @l0
		lda #EINVAL
		bra @errmsg

@l1:
    	lda paramptr
    	ldx paramptr+1
		ldy #O_WRONLY
    	jsr krn_open
		bne @err_close_fd1
		stx fd2

		;TODO copy loop

		jsr krn_close

		ldx fd1
		jsr krn_close

		jsr krn_primm
		.byte $0a," cp ok",$00
@exit:
		jmp (retvec)

@err_close:
		ldx fd2
		jsr krn_close
@err_close_fd1:
		pha
		ldx fd1
		jsr krn_close
		pla
@errmsg:
		;TODO FIXME maybe use oserror() from cc65 lib
		pha
		jsr krn_primm
		.asciiz "Error: "
		pla
		jsr hexout
		jmp @exit

.data
fd1:	.res 1
fd2:	.res 1
