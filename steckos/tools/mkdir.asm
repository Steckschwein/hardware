.include "common.inc"
.include "../kernel/kernel.inc"
.include "../kernel/kernel_jumptable.inc"

.include "appstart.inc"
appstart $1000

    	lda paramptr
    	ldx paramptr+1

		;TODO -p support by using krn_opendir and call krn_mkdir on "does not exist error"
		;
		jsr krn_mkdir
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
