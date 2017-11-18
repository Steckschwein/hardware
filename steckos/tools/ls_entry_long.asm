.segment "CODE"
.include "../kernel/kernel.inc"
.include "../kernel/kernel_jumptable.inc"
.include "../kernel/fat32.inc"
.include "../asminc/common.inc"


tmp0    = $a0
tmp1    = $a1
tmp2	= $a2


.import print_filename
.export dir_show_entry, pagecnt, entries_per_page, dir_attrib_mask

dir_show_entry:
		pha
		jsr print_filename

		lda #' '
		jsr krn_chrout

		ldy #F32DirEntry::Attr
		lda (dirptr),y


		bit #DIR_Attr_Mask_Volume
		beq @l1
		lda #'V'
		bra @l3
@l1:
		bit #DIR_Attr_Mask_Dir
		beq @l2
		lda #'D'
		bra @l3
@l2:
		lda #'F'
@l3:
		jsr krn_chrout
		lda #' '
		jsr krn_chrout

		ldy #F32DirEntry::FileSize +1
		lda (dirptr),y
		tax
		dey
		;ldy #F32DirEntry::FileSize
		lda (dirptr),y

		jsr dpb2ad

		lda #' '
		jsr krn_chrout

		ldy #F32DirEntry::WrtDate
		lda (dirptr),y
		and #%00011111
		jsr decoutz

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

		jsr decoutz

		lda #'.'
		jsr krn_chrout


		txa
		clc
		adc #80   	; add begin of msdos epoch (1980)
		cmp #100
		bcc @l6		; greater than 100 (post-2000)
		sec 		; yes, substract 100
		sbc #100
@l6:	jsr decoutz ; there we go


		lda #' '
		jsr krn_chrout


		ldy #F32DirEntry::WrtTime +1
		lda (dirptr),y
		tax
		lsr
		lsr
		lsr

		jsr decoutz

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

		jsr decoutz


        ; Bits 11–15: Hours, valid value range 0–23 inclusive.
        crlf


		pla
		rts

;----------------------------------------------------------------------------------------------
; decout - output byte in A as decimal ASCII without leading zeros
;----------------------------------------------------------------------------------------------
decout:
		phx
		phy
		ldx #1
		stx tmp1
		inx
		ldy #$40
@l1:
		sty tmp0
		lsr
@l2:	rol
		bcs @l3
		cmp dec_tbl,x
		bcc @l4
@l3:	sbc dec_tbl,x
		sec
@l4:	rol tmp0
		bcc @l2
		tay
		cpx tmp1
		lda tmp0
		bcc @l5
		beq @l6
		stx tmp1
@l5:	eor #$30
		jsr krn_chrout
@l6:	tya
		ldy #$10
		dex
		bpl @l1
		ply
		plx

		rts
decoutz:
		cmp #10
		bcs @l1
		pha
		lda #'0'
		jsr krn_chrout
		pla
@l1:
		jmp decout
 ; Lookup table for decimal to ASCII
dec_tbl:			.byte 128,160,200


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

;BIN:		.word 0
BCD:		.res 3
