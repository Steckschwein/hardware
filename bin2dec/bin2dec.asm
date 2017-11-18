.include "../steckos/kernel/kernel.inc"
.include "../steckos/kernel/kernel_jumptable.inc"
.include "../steckos/asminc/common.inc"

.include "../steckos/asminc/appstart.inc"
appstart $1000

			ldx #>12345
			lda #<12345
			jsr dpb2ad

			jmp (retvec)


dpb2ad:
			sta $31
			stx $32
			ldy #$00
nxtdig:

			ldx #$00
subem:		lda $31
			sec
			sbc subtbl,y
			sta $31
			lda $32
			iny
			sbc subtbl,y
			bcc adback
			sta $32
			inx
			dey
			bra subem

adback:

			dey
			lda $31
			adc subtbl,y
			sta $31
			txa
			ora #$30
			jsr krn_chrout
			iny
			iny
			cpy #08
			bcc nxtdig
			lda $31
			ora #$30


			jmp krn_chrout
;			rts

subtbl:		.word 10000
			.word 1000
			.word 100
			.word 10

BINBCD16:	SED		; Switch to decimal mode
		LDA #0		; Ensure the result is clear
		STA BCD+0
		STA BCD+1
		STA BCD+2
		LDX #16		; The number of source bits

CNVBIT:		ASL BIN+0	; Shift out one bit
		ROL BIN+1
		LDA BCD+0	; And add into result
		ADC BCD+0
		STA BCD+0
		LDA BCD+1	; propagating any carry
		ADC BCD+1
		STA BCD+1
		LDA BCD+2	; ... thru whole result
		ADC BCD+2
		STA BCD+2
		DEX		; And repeat for next bit
		BNE CNVBIT
		CLD		; Back to binary

		lda BCD+2
		jsr krn_hexout
		lda BCD+1
		jsr krn_hexout
		lda BCD
		jsr krn_hexout







; A test value to be converted



BIN:		.word  $ffff
BCD:		.res  3
