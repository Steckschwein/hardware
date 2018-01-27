.include "../../asminc/via.inc"
.include "../../asminc/common.inc"
.include "../../asminc/joystick.inc"
.include "../../asminc/lcd.inc"
.include "../../kernel/kernel.inc"

.export lcd_init_4bit, lcd_send_byte, lcd_command
.code
lcd_command:
	pha
	clear_bit LCD_RS, via1porta
	pla
	jsr lcd_send_byte
	jsr delay_40us
	set_bit LCD_RS, via1porta
	rts
; init lcd to 4bit mode
lcd_init_4bit:

	joy_off

	lda #$ff
	sta via1ddra

	lda #$00
	sta via1porta

	ldx #$00
@l:
	lda @init_bytes,x
	beq @part2
	sta via1porta
	jsr pulse_clock
	jsr delay_40us
	inx
	bne @l

@part2:

	ldx #$00
@l2:
	lda @init_bytes2,x
	beq @end
	jsr lcd_send_byte
	jsr delay_40us
	inx
	bne @l2

@end:
	set_bit LCD_RS, via1porta
	jmp delay_1ms
	;rts

@init_bytes:
	.byte $30, $30, $30, $20, $00
@init_bytes2:
	; 4bit mode, 2 line display
	.byte LCD_INST_FUNCTION_SET|LCD_BIT_FUNCTION_SET_N
	; display on, cursor on
	.byte LCD_INST_DISPLAY_ON_OFF|LCD_BIT_DISPLAY_ON_OFF_C|LCD_BIT_DISPLAY_ON_OFF_D
	.byte LCD_INST_SET_DDRAM_ADDR
	.byte LCD_INST_CLEAR_DISPLAY
	.byte $00


tmp = $cd

lcd_send_byte:
	phx
	tax

	lda via1porta
	and #$0f
	sta tmp

	txa
	and #$f0
	ora tmp
	sta via1porta
	jsr pulse_clock


	txa
	asl
	asl
	asl
	asl

	ora tmp
	sta via1porta
	jsr pulse_clock

	plx
    jmp delay_40us
	;rts

pulse_clock:
	inc via1porta
	nop
	nop
	dec via1porta

	rts

delay_40us:

	ldy #clockspeed / 8 * 40
@l:
			; 1cl = 125ns
	nop 	;2cl = 250ns
	nop 	;2cl = 250ns
	dey 	;2cl = 250ns
	bne @l
			;2cl = 250ns
			;      1000ns = 1us
	rts

delay_count = clockspeed * 1000 / 21
delay_1ms:
	lda #>delay_count
	sta val+1
	lda #<delay_count
	sta val
@l:
	dec16 val  ; max. 11 cl
	lda val+1  ; 2cl
	bne @l     ; 2/3cl
	lda val    ; 2cl
	bne @l     ; 2/3cl
	rts

val:
	.word $0000
