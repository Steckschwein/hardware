.include "common.inc"
.include "../kernel/kernel.inc"
.include "../kernel/kernel_jumptable.inc"

.include "appstart.inc"
appstart $1000

    	lda paramptr
    	ldx paramptr+1
		
    	jsr krn_unlink
		bne @errmsg
		
		jsr krn_primm
		.byte $0a," rm ok",$00
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