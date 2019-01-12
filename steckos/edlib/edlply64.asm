.setcpu "6502"
.include "common.inc"
.include "c64.inc"
.import jch_fm_init, jch_fm_play
.import _cputc

.export opl2_reg_write
;.export char_out=plot

.code
main:
		;jsr jch_detect_chip
		;bcc :+

		;jsr krn_primm
		;.byte "YM3526/YM3812 not available!",$0a,0
		;jmp exit

		jsr isD00File
		beq @init
		;       jsr krn_primm
		;      .byte "not a D00 file",$0a,0
		rts
		jmp exit

@init:
		sei

		jsr jch_fm_init
		;        jsr krn_primm
		;       .byte "edlib player v0.2 (somewhat optimized) by mr.mouse/xentax july 2017@",$0a,0
		; jsr printMetaData        
		;copypointer IRQVec, safe_isr

		;        lda #01
		;       sta VIC_IMR
		;      sta CIA1_ICR

		ldx #1
		lda #$20
		jsr opl2_reg_write

		lda #$ff
		sta VIC_IRR
		lda #0
		sta VIC_IMR

		lda #%00110101
		sta $01 ; i/o at d0000-dfff

		SetVector player_isr_rti, $fffa ;nmi
		SetVector player_isr, $fffe ;irq

		lda #$7f
		sta CIA1_ICR
		sta CIA2_ICR

		;70Hz => 1Mhz 1000000 / 70         
		lda #<(1000000 / 50)
		sta CIA1_TA
		lda #>(1000000 / 50)
		sta CIA1_TA+1

		lda #$91
		sta $dc0e
		lda #$81
		sta $dc0d

		cli



		lda #$fd
		sta $dc00
		and $dc01
		and #$80
		exit:
		jmp exit


player_isr:
		pha
		txa
		pha
		tya
		pha

		lda #$0f
		sta VIC_BORDERCOLOR
		sta VIC_BG_COLOR0

		jsr jch_fm_play

		lda #0
		sta VIC_BORDERCOLOR
		sta VIC_BG_COLOR0

		;inc VIC_IRR
		bit CIA1_ICR
		;jmp $ea31
		;jmp $febc
		pla 
		tay
		pla
		tax
		pla
		player_isr_rti:        
		rti


		opl2_reg_write:
		stx $df40               			;// select ym3526 register
		nop
		nop
		nop
		nop                     			;// wait 12 cycles for register select
		sta $df50               			;// write to it
		ldx #5
		lop:    dex
		nop
		bne lop                 			;// wait 36 cycles to do the next write        
		rts


		printMetaData:
		;        jsr krn_primm
		;       .asciiz "Name: "
		ldy #$0b
		jsr printString
		;        jsr krn_primm
		;.byte $0a,"Composer: ",0
		ldy #$2b
		jsr printString
		rts

		printString:
		ldx #$20
		:       
		txa
		pha
		tya
		pha
		lda d00file, y
		jsr _cputc
		pla
		tay
		pla
		tax
		iny 
		dex
		bne :- 
		rts

		isD00File:
		ldy #0
:		lda d00file, y
		cmp d00header,y
		bne :+
		iny 
		cpy #6
		bne :-
:		rts

d00header:
.byte "JCH",$26,$2,$66

safe_isr:   .res 2
.data
.export d00file
d00file:
.incbin "PJO_GALW.D00"
;.incbin "PJO_LAL.D00"
;.incbin "PJO_ARGH.D00"
;.incbin "PJO_KOER.D00"
;.incbin "MTL_NM11.D00"
;.incbin "VIB_FIS3.D00"

.segment "STARTUP"