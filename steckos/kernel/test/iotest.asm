.include "common.inc"
.include "errno.inc"
.include "fcntl.inc"	; @see ca65 fcntl.inc
.include "fat32.inc"	; @see ca65 fcntl.inc
.include "../kernel/kernel.inc"
.include "../kernel/kernel_jumptable.inc"

.include "appstart.inc"
appstart $1000

.import hexout

main:
		lda (paramptr)	; empty string?
		bne @l_cp
		lda #$99
		jmp errmsg
@l_cp:
		jsr krn_primm
		.asciiz "op r+"
    	lda paramptr
    	ldx paramptr+1
		ldy #O_CREAT
    	jsr krn_open
		jsr test_result
		stx fd1
		jsr krn_close

		jsr krn_primm
		.asciiz "op ro"
    	lda paramptr
    	ldx paramptr+1
		ldy #O_RDONLY
    	jsr krn_open
		jsr test_result
		stx fd1
		jsr krn_close
		
		jsr krn_primm
		.asciiz "op rw+"
    	lda paramptr
    	ldx paramptr+1
		ldy #O_WRONLY
    	jsr krn_open
		jsr test_result
		stx fd1
		
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
		jsr test_result
		
		jsr test_not_exist		
		jsr test_result
exit:
		jmp (retvec)

test_result:
		pha
		jsr krn_primm
		.asciiz " r="
		pla
		jsr hexout
		
		cmp #0
		bne @fail
		jsr krn_primm
		.byte " .",$0a,0
		rts
@fail:
		jsr krn_primm
		.byte " E",$0a,0
		rts 
		
test_not_exist:
		jsr krn_primm
		.asciiz "op r "
		lda #<file_notexist
		ldx #>file_notexist
		ldy #O_RDONLY
		jsr krn_open
		beq @fail	; anti test, expect open failed
		lda #0
		rts
@fail:	lda #$ff
		rts
		

errmsg:
		;TODO FIXME maybe use oserror() from cc65 lib
		pha
		jsr krn_primm
		.asciiz "Error: "
		pla
		jsr hexout
		jmp exit
file_notexist:
		.asciiz "notexist.dat"
fd1:	.res 1	
fd2:	.res 1
testdata:
		.byte "Hallo World!"
testdata_e: