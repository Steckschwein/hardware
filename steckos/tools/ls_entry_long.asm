.segment "CODE"
.include "../kernel/kernel.inc"
.include "../kernel/kernel_jumptable.inc"
.include "../kernel/fat32.inc"
.include "../asminc/common.inc"
.include "tools.inc"



.import print_filename, files, dirs
.export dir_show_entry, pagecnt, entries_per_page, dir_attrib_mask

dir_show_entry:
		pha
		jsr print_filename

		lda #' '
		jsr krn_chrout

		ldy #F32DirEntry::Attr
		lda (dirptr),y


		bit #DIR_Attr_Mask_Dir
		beq @l
		jsr krn_primm
		.byte "<DIR> ",$00
		inc dirs
		bra @date				; no point displaying directory size as its always zeros
								; just print some spaces and skip to date display
@l:
		ldy #F32DirEntry::FileSize +1
		lda (dirptr),y
		tax
		dey
		;ldy #F32DirEntry::FileSize
		lda (dirptr),y

		jsr dpb2ad

		lda #' '
		jsr krn_chrout
		inc files
@date:
		ldy #F32DirEntry::WrtDate

		lda (dirptr),y

		; day
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


		lda #' '
		jsr krn_chrout


		ldy #F32DirEntry::WrtTime +1
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

        ; Bits 11–15: Hours, valid value range 0–23 inclusive.
        crlf


		pla
		rts

b2ad:		phx
;			ldx #$00
;c100:		cmp #100
;			bcc out1
;			sbc #100
;			inx
;			bra c100
;out1:		jsr putout
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

dpb2ad:
			sta tmp0
			stx tmp1
			ldy #$00
			sty tmp2
nxtdig:

			ldx #$00
subem:		lda tmp0
			sec
			sbc subtbl,y
			sta tmp0
			lda tmp1
			iny
			sbc subtbl,y
			bcc adback
			sta tmp1
			inx
			dey
			bra subem

adback:

			dey
			lda tmp0
			adc subtbl,y
			sta tmp0
			txa
			bne setlzf
			bit tmp2
			bmi cnvta
			bpl printspc
setlzf:		ldx #$80
			stx tmp2

cnvta:		ora #$30
			jsr krn_chrout
			bra uptbl
printspc:
			lda #' '
			jsr krn_chrout

uptbl:		iny
			iny
			cpy #08
			bcc nxtdig
			lda tmp0
			ora #$30


			jmp krn_chrout
;			rts


subtbl:		.word 10000
			.word 1000
			.word 100
			.word 10



entries = 23
dir_attrib_mask:  .byte $0a

entries_per_page: .byte entries
pagecnt: .byte entries
