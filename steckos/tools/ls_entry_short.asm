.segment "CODE"
.include "../kernel/kernel.inc"
.include "../kernel/kernel_jumptable.inc"
.include "ls.inc"

.import print_filename
.export dir_show_entry

dir_show_entry:
		pha

		dec cnt 
		bne @l1
		crlf
		lda #$03
		sta cnt	
@l1:
		jsr print_filename
		lda #' '
		jsr krn_chrout
		pla

		rts