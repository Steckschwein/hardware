.include "../../kernel/kernel_jumptable.inc"
.include "../../kernel/kernel.inc"
.include "../../kernel/fat32.inc"

.include "../tools.inc"

.export print_filename, print_fat_date, print_fat_time, print_filesize
.import b2ad, dword2asc, char_out
.segment "CODE"
print_filename:
		ldy #F32DirEntry::Name
@l1:	lda (dirptr),y
		jsr char_out
		iny
		cpy #$0b
		bne @l1
		rts

print_fat_date:
		lda (dirptr),y
		and #%00011111
		jsr b2ad

		lda #'.'
		jsr char_out

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
		jsr char_out


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
		jsr char_out


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
		jsr char_out

		lda (dirptr),y
		and #%00011111

		jsr b2ad

		rts

print_filesize:
		phy
		lda dirptr
	    clc
	    adc #F32DirEntry::FileSize
	    tax
	    lda dirptr +1
	    adc #0
	    tay

	    lda #' '
	    jsr dword2asc

		stx $0a
	    sty $0b
	    ldy #0
	@l2:
	    lda ($0a),y
	    jsr char_out
	    iny
	    cpy #$06
	    bne @l2
		ply
		rts
