
.include "../steckos/kernel/kernel.inc"
.include "../steckos/kernel/kernel_jumptable.inc"
.include "../steckos/asminc/via.inc"
.include "../steckos/asminc/common.inc"
.include "../steckos/asminc/joystick.inc"

.include "../steckos/asminc/appstart.inc"

.include "lcd.inc"



.import hexout

	appstart $1000

	jsr lcd_init_4bit


@l:
	keyin
	cmp #$03
	bne @l1
 	jmp @end
@l1:
	cmp #$1b
	bne @l2
	jmp @end
@l2:
	cmp #'<'
	bne @next

	lda #LCD_INST_SHIFT|LCD_BIT_SHIFT_SC
	jsr lcd_command
	bra @l

@next:
	cmp #'>'
	bne @next2

	lda #LCD_INST_SHIFT|LCD_BIT_SHIFT_RL|LCD_BIT_SHIFT_SC
	jsr lcd_command
	bra @l


@next2:
	cmp #$12
	bne @next3

	lda #LCD_INST_CURSOR_HOME
	jsr lcd_command
	bra @l

@next3:
	cmp #$1F
	bne @next4

	lda #LCD_INST_SET_DDRAM_ADDR|$40
	jsr lcd_command
	jmp @l

@next4:
	cmp #$1E
	bne @next5

	lda #LCD_INST_SET_DDRAM_ADDR
	jsr lcd_command
	jmp @l

@next5:
	cmp #$11
	bne @next6

	lda #LCD_INST_SHIFT
	jsr lcd_command
	bra @l

@next6:
	cmp #$10
	bne @next7

	lda #LCD_INST_SHIFT|LCD_BIT_SHIFT_RL
	jsr lcd_command
	bra @l

@next7:
	cmp #$08
	bne @out

	lda #LCD_INST_SHIFT
	jsr lcd_command
	lda #' '

	

@out:
	jsr hexout
	jsr lcd_send_byte
	jsr delay_40us
	jmp @l



@end:
	;jmp (retvec)
	jmp krn_upload


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
	jmp delay
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


lcd_send_byte:
	phx
	tax

	lda via1porta
	and #$0f
	sta via1porta

	txa
	and #$f0
	ora via1porta
	sta via1porta
	jsr pulse_clock

	lda via1porta
	and #$0f
	sta via1porta



	txa

	asl
	asl
	asl
	asl

	ora via1porta
	sta via1porta
	jsr pulse_clock
	plx
	rts

pulse_clock:
	inc via1porta
	nop
	nop
	dec via1porta

	rts

delay_40us:

	ldy #40
@l:
			; 1cl = 125ns
	nop 	;2cl = 250ns
	nop 	;2cl = 250ns
	dey 	;2cl = 250ns
	bne @l
			;2cl = 250ns
			;      1000ns = 1us
	rts

delay:
	phy
	phx
	ldy #4
@loop2:
	ldx #250
@loop1:
	.repeat 5
	nop
	.endrepeat

	dex
	bne @loop1
	dey
	bne @loop2
	plx
	ply
	rts
