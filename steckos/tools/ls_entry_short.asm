.segment "CODE"
.include "../kernel/kernel.inc"
.include "../kernel/kernel_jumptable.inc"


.import print_filename, cnt
.export dir_show_entry, pagecnt, entries_per_page

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

entries = 69
entries_per_page: .byte entries
pagecnt: .byte entries
