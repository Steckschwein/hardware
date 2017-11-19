
.include "common.inc"
.include "../kernel/kernel.inc"
.include "../kernel/kernel_jumptable.inc"
.include "../kernel/fat32.inc"
.include "appstart.inc"

.export print_filename, cnt, files, dirs
.import dir_show_entry, pagecnt, entries_per_page, dir_attrib_mask

appstart $1000
main:

		; lda #$04
		; sta cnt
l1:
		crlf
		SetVector pattern, filenameptr

		lda (paramptr)
		beq @l2
		copypointer paramptr, filenameptr

@l2:
		ldx #FD_INDEX_CURRENT_DIR
		jsr krn_find_first
		bcs @l2_1

		printstring "i/o error"
		jmp (retvec)

@l2_1:	bcs @l4
		bra @l5
		; jsr .dir_show_entry
@l3:
		ldx #FD_INDEX_CURRENT_DIR
		jsr krn_find_next
		bcc @l5
@l4:
		lda (dirptr)
		cmp #$e5
		beq @l3

		ldy #F32DirEntry::Attr
		lda (dirptr),y

		bit dir_attrib_mask ; Hidden attribute set, skip
		bne @l3


		jsr dir_show_entry

		dec pagecnt
		bne @l
		keyin
		cmp #13 ; enter pages line by line
		beq @lx
		cmp #$03 ; CTRL-C
		beq @l5

		lda entries_per_page
		sta pagecnt
		bra @l
@lx:
		lda #1
		sta pagecnt

@l:

		jsr krn_getkey
		cmp #$03 ; CTRL-C?
		beq @l5
		bra @l3
@l5:

		lda files
		beq @dirs
		jsr b2ad
		jsr krn_primm
		.byte " file(s)",$0a,$00
@dirs:
		lda dirs
		beq @end
		jsr b2ad
		jsr krn_primm
		.byte " dir(s)",$0a,$00

@end:

		jmp (retvec)

b2ad:		phx
			ldx #$00
c100:		cmp #100
			bcc out1
			sbc #100
			inx
			bra c100
out1:		jsr putout
			ldx #$00
c10:		cmp #10
			bcc out2
			sbc #10
			inx
			bra c10
out2:		jsr putout
			clc
			adc #$30
			jsr krn_chrout
			plx
			rts

putout:		pha
			txa
			adc #$30
			jsr krn_chrout
			pla
			rts


print_filename:
		ldy #F32DirEntry::Name
@l1:		lda (dirptr),y
		jsr krn_chrout
		iny
		cpy #$0b
		bne @l1
		rts

pattern:			.byte "*.*",$00
cnt: 	.byte $04
dirs:	.byte $00
files:	.byte $00
