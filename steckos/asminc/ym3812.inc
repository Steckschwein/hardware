; MIT License
;
; Copyright (c) 2018 Thomas Woinke, Marko Lauke, www.steckschein.de
;
; Permission is hereby granted, free of charge, to any person obtaining a copy
; of this software and associated documentation files (the "Software"), to deal
; in the Software without restriction, including without limitation the rights
; to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
; copies of the Software, and to permit persons to whom the Software is
; furnished to do so, subject to the following conditions:
;
; The above copyright notice and this permission notice shall be included in all
; copies or substantial portions of the Software.
;
; THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
; IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
; FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
; AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
; LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
; OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
; SOFTWARE.

.ifndef _YM3812_INC_
.define _YM3812_INC_

.include "system.inc"

opl_stat = $0240        ; status register
opl_sel  = opl_stat		; register select
opl_data = opl_stat + 1 ; data register (write only)

opl2_data_delay_time = 23000 ; ns
opl2_reg_delay_time = 3300 ; ns

opl2_data_delay 	= (((opl2_data_delay_time - opl2_reg_delay_time) / (1000/clockspeed)) -12) / 2
opl2_reg_delay 		= ((opl2_reg_delay_time 							/ (1000/clockspeed)) -12) / 2

opl2_s_irq		= 1<<7	; timer irq 
opl2_s_irq_t1	= 1<<6	; ... irq cause of t1
opl2_s_irq_t2	= 1<<5	; ... irq cause of t2

opl2_reg_t1 = 2
opl2_reg_t2 = 3
opl2_reg_ctrl   = 4

;--------------------------------------------------------------------------------------------------------------
; For some of the parameters, there is one register per output channel. For those
; parameters, channel number can be used as an offset into the map. For many
; parameters, there is one register per operator. However, there are holes in the
; address map so that in this case, the operator number CANNOT be used as an
; offset. The operator offsets for those registers are (in hex form):
;--------------------------------------------------------------------------------------------------------------
opl2_op1 	= $00
opl2_op2 	= $01
opl2_op3 	= $02
opl2_op4 	= $03
opl2_op5 	= $04
opl2_op6 	= $05
opl2_op7 	= $08
opl2_op8 	= $09
opl2_op9 	= $0A
opl2_op10 	= $0B
opl2_op11 	= $0C
opl2_op12 	= $0D
opl2_op13 	= $10
opl2_op14 	= $11
opl2_op15 	= $12
opl2_op16 	= $13
opl2_op17 	= $14
opl2_op18 	= $15
;--------------------------------------------------------------------------------------------------------------
opl2_chan0_op1	= opl2_op1
opl2_chan0_op2	= opl2_op4

opl2_chan1_op1	= opl2_op2
opl2_chan1_op2	= opl2_op5

opl2_chan2_op1	= opl2_op3
opl2_chan2_op2	= opl2_op6

opl2_chan3_op1	= opl2_op7
opl2_chan3_op2	= opl2_op10

opl2_chan4_op1	= opl2_op8
opl2_chan4_op2	= opl2_op11

opl2_chan5_op1	= opl2_op9
opl2_chan5_op2	= opl2_op12

opl2_chan6_op1	= opl2_op13
opl2_chan6_op2	= opl2_op16

opl2_chan7_op1	= opl2_op14
opl2_chan7_op2	= opl2_op17

opl2_chan8_op1	= opl2_op15
opl2_chan8_op2	= opl2_op18
;--------------------------------------------------------------------------------------------------------------


.macro oplSetRegVal reg, val
	lda #reg
	sta opl_stat
	; http://www.shipbrook.net/jeff/sb.html
	; The AdLib manual gives the wait times in microseconds: three point three (3.3) microseconds for the address, and twenty-three (23) microseconds for the data.
	; 3.300 ns / 0.25ns = 13.2 cycles / 2 = 6.6 NOPs

	.repeat opl2_reg_delay
		nop
	.endrepeat

	lda #val
	sta opl_data
	; 23.000 ns / 0.25ns = 92 cycles / 92 = 46 NOPs
	ldy #opl2_data_delay
:
	dey
	bne :-

.endmacro

.macro oplSetReg reg
	pha
	lda #reg
	sta opl_stat
	; http://www.shipbrook.net/jeff/sb.html
	; The AdLib manual gives the wait times in microseconds: three point three (3.3) microseconds for the address, and twenty-three (23) microseconds for the data.
	; 3.300 ns / 0.25ns = 13.2 cycles / 2 = 6.6 NOPs

	.repeat opl2_reg_delay
		nop
	.endrepeat
	pla
	sta opl_data
	; 23.000 ns / 0.25ns = 92 cycles / 92 = 46 NOPs
	; !for .i,1,46 {
	; 	nop
	; }
	ldy #opl2_data_delay
:
	dey
	bne :-
.endmacro

.endif