; control lines
LCD_E 	= (1<<0)
LCD_RS 	= (1<<1)
LCD_RW 	= (1<<2)

; instructions
LCD_INST_CLEAR_DISPLAY  = (1<<0)
LCD_INST_CURSOR_HOME    = (1<<1)
LCD_INST_ENTRY_MODE_SET = (1<<2)
LCD_INST_DISPLAY_ON_OFF = (1<<3)
LCD_INST_SHIFT          = (1<<4)
LCD_INST_FUNCTION_SET   = (1<<5)
LCD_INST_SET_CGRAM_ADDR = (1<<6)
LCD_INST_SET_DDRAM_ADDR = (1<<7)

;parameter bits
LCD_BIT_ENTRY_MODE_SET_ID = (1<<1) ; increment or decrement position
LCD_BIT_ENTRY_MODE_SET_S  = (1<<2) ; display shift

LCD_BIT_DISPLAY_ON_OFF_D = (1<<2) ; Display on/off
LCD_BIT_DISPLAY_ON_OFF_C = (1<<1) ; cursor on/off
LCD_BIT_DISPLAY_ON_OFF_B = (1<<0) ; cursor blink on/off

LCD_BIT_SHIFT_SC         = (1<<3) ; 0=move cursor, 1=shift Display
LCD_BIT_SHIFT_RL         = (1<<2) ; 0=shift left, 1=shift right

LCD_BIT_FUNCTION_SET_DL  = (1<<4) ; 0=4bit interface, 1=8bit interface
LCD_BIT_FUNCTION_SET_N   = (1<<3) ; 0=1line display, 1=2line display
LCD_BIT_FUNCTION_SET_F   = (1<<2) ; 0=5x7 dots, 1=5x10 dots
