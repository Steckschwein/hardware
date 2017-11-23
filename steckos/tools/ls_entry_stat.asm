.segment "CODE"
.include "../kernel/kernel.inc"
.include "../kernel/kernel_jumptable.inc"
.include "../kernel/fat32.inc"


tmp0    = $a0
tmp1    = $a1



.import print_filename
.import b2ad, dpb2ad

.export dir_show_entry, pagecnt, entries_per_page, dir_attrib_mask

dir_show_entry:
		pha
		jsr krn_primm
		.byte "Name: ",$00
		jsr print_filename
		crlf

		jsr krn_primm
		.byte "Size: ",$00
		ldy #F32DirEntry::FileSize +1
		lda (dirptr),y
		tax
		ldy #F32DirEntry::FileSize
		lda (dirptr),y
		jsr dpb2ad

		jsr krn_primm
		.byte "  Cluster#1: ",$00

		ldy #F32DirEntry::FstClusHI+1
		lda (dirptr),y
		jsr krn_hexout
		dey
		lda (dirptr),y
		jsr krn_hexout
		ldy #F32DirEntry::FstClusLO+1
		lda (dirptr),y
		jsr krn_hexout
		dey
		lda (dirptr),y
		jsr krn_hexout

		crlf

		jsr krn_primm
		.byte "Attribute: "
		.byte "--ADVSHR",$00
		crlf

		jsr krn_primm
		.byte "           ",$00

		ldy #F32DirEntry::Attr
		lda (dirptr),y
		ldx #$07
@l:
		rol
		bcc @skip
		pha
		lda #'1'
		bra @out
@skip:
		pha
		lda #'0'
@out:
		jsr krn_chrout
		pla
		dex
		bpl @l
		crlf


		jsr krn_primm
		.byte "Created  : ",$00
		ldy #F32DirEntry::CrtDate
		jsr print_fat_date

		lda #' '
		jsr krn_chrout

		ldy #F32DirEntry::CrtTime +1
		jsr print_fat_time
		crlf

		jsr krn_primm
		.byte "Modified : ",$00
		ldy #F32DirEntry::WrtDate
		jsr print_fat_date

		lda #' '
		jsr krn_chrout

		ldy #F32DirEntry::WrtTime +1
		jsr print_fat_time
		crlf

		pla
		rts

print_fat_date:
		lda (dirptr),y
		and #%00011111
		jsr b2ad

		lda #'.'
		jsr krn_chrout

		; month
		iny
		lda (dirptr),y
		lsr
		tax
		dey
		lda (dirptr),y
		ror
		lsr
		lsr
		lsr
		lsr

		jsr b2ad

		lda #'.'
		jsr krn_chrout


		txa
		clc
		adc #80   	; add begin of msdos epoch (1980)
		cmp #100
		bcc @l6		; greater than 100 (post-2000)
		sec 		; yes, substract 100
		sbc #100
@l6:	jsr b2ad ; there we go

		rts

print_fat_time:
		lda (dirptr),y
		tax
		lsr
		lsr
		lsr

		jsr b2ad

		lda #':'
		jsr krn_chrout


		txa
		and #%00000111
		sta tmp1
		dey
		lda (dirptr),y

		.repeat 5
		lsr tmp1
		ror
		.endrepeat

		jsr b2ad

		rts



entries = 3
entries_per_page: .byte entries
pagecnt: .byte entries
dir_attrib_mask:  .byte $08
