.include "common.inc"
.include "errno.inc"
.include "fcntl.inc"	; @see ca65 fcntl.inc
.include "fat32.inc"	; @see ca65 fcntl.inc
.include "../kernel/kernel.inc"
.include "../kernel/kernel_jumptable.inc"

.include "appstart.inc"
appstart $1000

main:
		lda (paramptr)	; empty string?
		bne @l_cp
		lda #$99
		bra @errmsg
@l_cp:

    	lda paramptr
    	ldx paramptr+1
		ldy #O_CREAT
    	jsr krn_open
		bne @errmsg
		stx fd1
		jsr krn_primm
		.byte "op r+",$0a,0
		jsr krn_close

    	lda paramptr
    	ldx paramptr+1
		ldy #O_RDONLY
    	jsr krn_open
		bne @errmsg
		stx fd1
		jsr krn_primm
		.byte "op ro",$0a,0
		jsr krn_close
		
    	lda paramptr
    	ldx paramptr+1
		ldy #O_WRONLY
    	jsr krn_open
		bne @errmsg
		stx fd1
		jsr krn_primm
		.byte "op rw+",$0a,0

		lda #<testdata
		sta write_blkptr+0
		lda #>testdata
		sta write_blkptr+1
		lda #testdata_e-testdata
		sta fd_area + F32_fd::FileSize + 0,x
		stz fd_area + F32_fd::FileSize + 1,x
		stz fd_area + F32_fd::FileSize + 2,x
		stz fd_area + F32_fd::FileSize + 3,x
		jsr krn_write
		jsr krn_close
		bne @errmsg
		
		
@exit:
		jmp (retvec)
		 
@errmsg:
		;TODO FIXME maybe use oserror() from cc65 lib
		pha
		jsr krn_primm
		.asciiz "Error: "
		pla
		jsr krn_hexout
		jmp @exit
		
fd1:	.res 1	
fd2:	.res 1
testdata:
		.byte "Hallo World!"
testdata_e: