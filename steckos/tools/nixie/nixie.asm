.include	"common.inc"
.include	"vdp.inc"
.include	"zeropage.inc"
.include	"../../kernel/zeropage.inc"
.include	"../../kernel/kernel_jumptable.inc"

.import		vdp_bgcolor
.import		vdp_gfx2_on
.import		vdp_gfx2_blank
.import		vdp_memcpys

.include "appstart.inc"
appstart $1000

CHAR_BLANK=$ff

.code
main:
			sei
			jsr	krn_textui_disable
			jsr	krn_display_off

			lda	#Black<<4|Black
			jsr	vdp_gfx2_blank
			jsr	init_digits
			jsr	init_screen
			
			jsr	vdp_gfx2_on
			
			copypointer	$fffe, irqsave
			SetVector	isr, $fffe
			
			stz display_datetime
			
			cli
			
@0:			jsr	krn_getkey
			cmp #KEY_ESCAPE
			beq exit
			cmp #'x'
			beq exit
			cmp #'d'
			bne @0
			lda	#05
			sta display_datetime
			
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
			lda #5
			sta frmcnt
			jsr update_screen
			jsr update_datetime
			jsr draw_digits			
@0:
			lda #Black
			jsr vdp_bgcolor
			
			ply
			plx
			pla
@e:
			rti

update_datetime:
@0:			
			jsr	krn_spi_select_rtc
			lda display_datetime
			bne	@date
@time:
			lda #0 ; read from rtc, start with seconds
			jsr krn_spi_rw_byte

			jsr krn_spi_r_byte    ;seconds
			ldy	#7 				  ; offset in datetime - end of time
			jsr to_number			
			dey					  ;space
			
			jsr krn_spi_r_byte     ;minute
			jsr to_number
			dey					  ;space
			
			jsr krn_spi_r_byte     ;hour
			jsr to_number
			bra @exit
@date:
			dec display_datetime
			lda #4 					; read from rtc, start with day of month
			jsr krn_spi_rw_byte

			jsr krn_spi_r_byte     	;day of month
			ldy	#1					; offset in datetime - end of date
			jsr to_number
			
			jsr krn_spi_r_byte     ;month - dc1306 gives 1-12, but 0-11 expected
			ldy	#4
			jsr to_number
			
			jsr krn_spi_r_byte     ;year value - rtc yeat 2000+year register
			ldy	#7
			jsr to_number
@exit:
			jmp krn_spi_deselect

to_number:
			pha 
			and #$0f
			sta datetime, y
			dey
			pla 
			lsr
			lsr
			lsr
			lsr
			and #$0f
			sta datetime, y
			dey
			rts
			
update_screen:
			SetVector screen_buffer, ptr1
			lda	#<(ADDRESS_GFX2_SCREEN+256*1)
			ldy	#WRITE_ADDRESS+>(ADDRESS_GFX2_SCREEN+256*1)
			ldx #2
			bra vram_copy_x

init_digits:
			;5 rows 1st pattern/color bank
			SetVector tab_pattern, ptr1
			lda	#<(ADDRESS_GFX2_PATTERN+($0800*1));pattern for 2nd screen bank
			ldy	#WRITE_ADDRESS+>(ADDRESS_GFX2_PATTERN+(2048*1))
			jsr vram_copy
			;4 rows 2nd pattern/color bank
			SetVector (tab_pattern+$0800), ptr1
			lda	#<(ADDRESS_GFX2_PATTERN+($0800*2));pattern for 3rd screen bank
			ldy	#WRITE_ADDRESS+>(ADDRESS_GFX2_PATTERN+(2048*2))
			jsr vram_copy
			
			;5 rows 1st pattern/color bank
			SetVector tab_color, ptr1
			lda	#<(ADDRESS_GFX2_COLOR+($0800*1))
			ldy	#WRITE_ADDRESS+>(ADDRESS_GFX2_COLOR+(2048*1))
			jsr vram_copy
			;4 rows 2nd pattern/color bank
			SetVector (tab_color+$0800), ptr1
			lda	#<(ADDRESS_GFX2_COLOR+($0800*2))
			ldy	#WRITE_ADDRESS+>(ADDRESS_GFX2_COLOR+(2048*2))
			jmp vram_copy

vram_copy:
			ldx #8			
vram_copy_x:
			vdp_sreg
			jmp	copy

datetime:	.byte 0,0, $ff,0,0,$ff,0,0,$ee; date/time buffer

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
			
datetime_ix=tmp1
screen_x=tmp2
digit_pos=tmp3
display_datetime=tmp4

draw_digits:
			stz datetime_ix
			stz screen_x
			
@2:			ldy datetime_ix
			ldx datetime, y
			cpx #$ee
			beq @ex
			cpx #$ff
			bne	@0
			inc screen_x
			bra @1
@0:			jsr draw_digit
@1:			inc datetime_ix
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

.data			
digit_offset:
	.repeat 10, i
		.byte i*5
	.endrep
	
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
screen_buffer:
	.res 256,CHAR_BLANK
	.res 256,CHAR_BLANK
    
.segment "STARTUP"