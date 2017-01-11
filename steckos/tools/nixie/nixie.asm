.include	"common.inc"
.include	"vdp.inc"
.include	"zeropage.inc"
.include	"../../kernel/zeropage.inc"
.include	"../../kernel/kernel_jumptable.inc"

;.import		krn_spi_select_rtc, krn_spi_deselect
;.import		krn_spi_r_byte

.import		vdp_bgcolor
.import		vdp_mode_gfx2
.import		vdp_mode_gfx2_blank
.import		vdp_memcpys


CHAR_BLANK=$ff
row=tmp1
.code
main:
			sei
			jsr	krn_textui_disable
			jsr	krn_display_off

			lda	#Black<<4|Black
			jsr	init_digits
			jsr	init_screen
			
			jsr	vdp_mode_gfx2
			
			copypointer	$fffe, irqsave
			SetVector	isr, $fffe
			
			stz tmp2
			
			cli
			
@0:			jsr	krn_getkey
			cmp #$03
			beq exit
			cmp #'x'
			beq exit
			bra @0
exit:			
			sei
			copypointer	irqsave, $fffe
			jsr	krn_textui_init
			cli
			jmp	(retvec)
			
isr:
			bit	a_vreg
			bpl	@e
			pha
			phx
			phy

;			lda #Dark_Yellow
;			jsr vdp_bgcolor
				
			dec	frmcnt
			bne	@0
			lda #50
			sta frmcnt
			jsr update_screen
			jsr update_time
			jsr draw_digits
@0:
			lda #Black
			jsr vdp_bgcolor
			
			ply
			plx
			pla
@e:
			rti

update_time:
			jsr	krn_spi_select_rtc
			
			lda #0 ; read from rtc, start with seconds
			jsr krn_spi_rw_byte

			ldy	#7 				  ; offset to number
			jsr krn_spi_r_byte    ;seconds
			jsr to_number			
			dey					  ;space
			
			jsr krn_spi_r_byte     ;minute
			jsr to_number
			dey					  ;space
			
			jsr krn_spi_r_byte     ;hour
			jsr to_number
			
;			jsr krn_spi_r_byte     ;week day
;			sta TM+tm::tm_wday
;			jsr krn_spi_r_byte     ;day of month
;			jsr BCD2dec
;			sta TM+tm::tm_mday
;
;			jsr krn_spi_r_byte     ;month
;			dec                     ;dc1306 gives 1-12, but 0-11 expected
;			jsr BCD2dec
;			sta TM+tm::tm_mon
;
;			jsr krn_spi_r_byte     ;year value - rtc yeat 2000+year register
;			jsr BCD2dec
;			clc
;			adc #100                ;TM starts from 1900, so add the difference
;			sta TM+tm::tm_year

			jsr krn_spi_deselect
			rts

to_number:
			pha 
			and #$0f
			sta number, y
			dey
			pla 
			lsr
			lsr
			lsr
			lsr
			and #$0f
			sta number, y
			dey
			rts
			
; dec = (((BCD>>4)*10) + (BCD&0xf))
BCD2dec:tax
        and     #%00001111
        sta     tmp1
        txa
        and     #%11110000      ; *16
        lsr                     ; *8
        sta     tmp2
        lsr
        lsr                     ; *2
        adc     tmp2            ; = *10
        adc     tmp1
        rts
			
update_screen:
			lda	#<(ADDRESS_GFX2_SCREEN+256*1)
			ldy	#WRITE_ADDRESS+>(ADDRESS_GFX2_SCREEN+256*1)
			vdp_sreg
			SetVector screen_buffer, ptr1
			ldx #2
			jmp copy

init_digits:
			;5 rows 1st pattern/color bank
			lda	#<(ADDRESS_GFX2_PATTERN+($0800*1));pattern for 2nd screen bank
			ldy	#WRITE_ADDRESS+>(ADDRESS_GFX2_PATTERN+(2048*1))
			vdp_sreg
			SetVector tab_pattern, ptr1
			ldx #8
			jsr	copy
			;4 rows 2nd pattern/color bank
			lda	#<(ADDRESS_GFX2_PATTERN+($0800*2));pattern for 3rd screen bank
			ldy	#WRITE_ADDRESS+>(ADDRESS_GFX2_PATTERN+(2048*2))
			vdp_sreg
			SetVector (tab_pattern+$0800), ptr1
			ldx #8
			jsr	copy
			
			;5 rows 1st pattern/color bank
			lda	#<(ADDRESS_GFX2_COLOR+($0800*1))
			ldy	#WRITE_ADDRESS+>(ADDRESS_GFX2_COLOR+(2048*1))
			vdp_sreg
			SetVector tab_color, ptr1
			ldx #8
			jsr	copy
			;4 rows 2nd pattern/color bank
			lda	#<(ADDRESS_GFX2_COLOR+($0800*2))
			ldy	#WRITE_ADDRESS+>(ADDRESS_GFX2_COLOR+(2048*2))
			vdp_sreg
			SetVector (tab_color+$0800), ptr1
			ldx #8
			jmp	copy

number:	.byte 0,1,$ff,2,3,$ff,4,5,$ee

init_screen:
			lda	#<(ADDRESS_GFX2_SCREEN+256*1)
			ldy	#WRITE_ADDRESS+>(ADDRESS_GFX2_SCREEN+256*1)
			vdp_sreg
			ldx #0
			ldy #2
			lda #CHAR_BLANK
@0:			sta a_vram
			vnops
			inx
			bne @0
			dey 
			bne @0
			rts
			
number_ix=tmp1
screen_x=tmp2
digit_pos=tmp3

draw_digits:
			stz number_ix
			stz screen_x
			
@2:			ldy number_ix
			ldx number, y
			cpx #$ee
			beq @ex
			cpx #$ff
			bne	@0
			inc screen_x
			bra @1
@0:			jsr draw_digit
@1:			inc number_ix
			bra @2
@ex:		rts

			; x - number
draw_digit:
			lda #5
			sta digit_pos
			ldy digit_offset, x
			ldx	screen_x
@0:			lda digit_tab+00, y
			sta screen_buffer+$60, x
			lda digit_tab+50, y
			sta screen_buffer+$80, x
			lda digit_tab+100, y
			sta screen_buffer+$a0, x
			lda digit_tab+150, y
			sta screen_buffer+$c0, x
			lda digit_tab+200, y
			sta screen_buffer+$e0, x
			lda digit_tab+00, y
			sta screen_buffer+$100, x
			lda digit_tab+50, y
			sta screen_buffer+$120, x
			lda digit_tab+100, y
			sta screen_buffer+$140, x
			lda digit_tab+150, y
			sta screen_buffer+$160, x
			iny
			inx
			dec digit_pos
			bne @0
			stx screen_x
			rts
			
copy:
			ldy #0
@0:			lda (ptr1), y
			vnops
			sta a_vram
			iny
			bne	@0
			inc ptr1+1
			dex
			bne @0
			rts
			
irqsave:	.res 2
frmcnt:		.res 1, 1
			
m_vdp_nopslide

.align 256
digit_tab:
	.repeat 250, i
		.byte i
	.endrep

.align 256
tab_color:
.incbin "DIGITS_0-9.reorg.tiac"
tab_pattern:
.incbin	"DIGITS_0-9.reorg.tiap"
.align 256
screen_buffer:
	.res 256,CHAR_BLANK
	.res 256,CHAR_BLANK
	
digit_offset:
	.repeat 10, i
		.byte i*5
	.endrep