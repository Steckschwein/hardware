.include "common.inc"
.include "kernel.inc"
.include "kernel_jumptable.inc"

.include "appstart.inc"
.import hexout
appstart $1000

    	lda paramptr
    	ldx paramptr+1

    	jsr krn_rmdir
		bne @errmsg

		jsr krn_primm
		.byte $0a," rmdir ok",$00
@exit:
		jmp (retvec)

@errmsg:
		;TODO FIXME maybe use oserror() from cc65 lib
		pha
		jsr krn_primm
		.asciiz "Error: "
		pla
		jsr hexout
		jmp @exit
