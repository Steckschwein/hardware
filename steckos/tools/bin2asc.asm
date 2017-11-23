.include "../kernel/kernel_jumptable.inc"
.include "tools.inc"

.export b2ad, b2ad2, dpb2ad

.segment "CODE"
b2ad:		phx
			ldx #$00
@c10:		cmp #10
			bcc @out2
			sbc #10
			inx
			bra @c10
@out2:		jsr putout
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

b2ad2:		phx
			ldx #$00
@c100:		cmp #100
			bcc @out1
			sbc #100
			inx
			bra @c100
@out1:		jsr putout
			ldx #$00
@c10:		cmp #10
			bcc @out2
			sbc #10
			inx
			bra @c10
@out2:		jsr putout
			clc
			adc #$30
			jsr krn_chrout
			plx
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
