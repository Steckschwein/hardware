.setcpu "65c02"

.include "../kernel/kernel.inc"
.include "ym3812.inc"
.export init_opl2, opl2_delay_data, opl2_delay_register
;----------------------------------------------------------------------------------------------	
; "init" opl2 by writing zeros into all registers
;----------------------------------------------------------------------------------------------
init_opl2:
	ldx #$F5 ; until reg 245
@l1:
	stx opl_stat

	jsr opl2_delay_register

	stz opl_data

	jsr opl2_delay_data

	dex
	bne @l1
	
	rts


; jsr here: 6 cycles
; rts back: 6 cycles



opl2_delay_data: ; 23000ns / 0
.repeat opl2_data_delay
	nop
.endrepeat

opl2_delay_register: ; 3300 ns
.repeat opl2_reg_delay
	nop
.endrepeat
	rts
