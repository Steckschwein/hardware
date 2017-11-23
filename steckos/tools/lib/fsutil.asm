.include "../../kernel/kernel_jumptable.inc"
.include "../../kernel/kernel.inc"
.include "../../kernel/fat32.inc"

.include "../tools.inc"

.export print_filename, print_fat_date, print_fat_time
.import b2ad

print_filename:
		ldy #F32DirEntry::Name
@l1:	lda (dirptr),y
		jsr krn_chrout
		iny
		cpy #$0b
		bne @l1
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

		lda #':'
		jsr krn_chrout

		lda (dirptr),y
		and #%00011111

		jsr b2ad

		rts
