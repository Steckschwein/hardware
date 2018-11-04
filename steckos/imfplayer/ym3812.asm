; MIT License
;
; Copyright (c) 2018 Thomas Woinke, Marko Lauke, www.steckschwein.de
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

.setcpu "65c02"

.include "kernel.inc"
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
