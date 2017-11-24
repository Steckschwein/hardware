.include "common.inc"
.include "errno.inc"
.include "fcntl.inc"	; @see ca65 fcntl.inc
.include "../kernel/kernel.inc"
.include "../kernel/kernel_jumptable.inc"

.include "appstart.inc"
.import hexout
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
