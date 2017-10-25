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


		ror
		ror
		ror
		bcc @l1
		lda #'V'
		bra @l4
@l1:
		ror
		bcc @l2
		lda #'S'
		bra @l4
@l2:
		ror
		bcc @l3
		lda #'D'
		bra @l4
@l3:
		lda #'F'
@l4:
		jsr krn_chrout
		lda #' '
		jsr krn_chrout

		ldy #F32DirEntry::FileSize +1
		lda (dirptr),y
		tax
		ldy #F32DirEntry::FileSize
		lda (dirptr),y

		jsr BINBCD16

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

BINBCD16:
                sta tmp0
		stx tmp0+1
	        SED             ; Switch to decimal mode
                LDA #0          ; Ensure the result is clear
                STA BCD+0
                STA BCD+1
                STA BCD+2
                LDX #16         ; The number of source bits

CNVBIT:         ASL tmp0+0       ; Shift out one bit
                ROL tmp0+1
                LDA BCD+0       ; And add into result
                ADC BCD+0
                STA BCD+0
                LDA BCD+1       ; propagating any carry
                ADC BCD+1
                STA BCD+1
                LDA BCD+2       ; ... thru whole result
                ADC BCD+2
                STA BCD+2
                DEX             ; And repeat for next bit
                BNE CNVBIT
                CLD             ; Back to binary


		lda BCD+2
		jsr krn_hexout
		lda BCD+1
		jsr krn_hexout
		lda BCD
		jsr krn_hexout

		rts

entries = 23
dir_attrib_mask:  .byte $0a

entries_per_page: .byte entries
pagecnt: .byte entries

;BIN:		.word 0
BCD:		.res 3
