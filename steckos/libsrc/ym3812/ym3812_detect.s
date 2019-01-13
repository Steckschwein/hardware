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

.export opl2_detect

.include "ym3812.inc"
.importzp tmp1
.import opl2_reg_write
;// ----------------------------------------------------------------------------------------------------------
;// JCH_DETECT_CHIP ;// CHECK CHIP EXISTENCE ;// NEED REAL HARDWARE TO WORK (NOT EMULATION)
;// returns carry set if fail
;// ----------------------------------------------------------------------------------------------------------
opl2_detect:
loc_1062B:			
		sei									;// sure? disable interrupts
		jsr __opl2_reset_timer
		ldx #opl2_reg_ctrl							;// set timer control byte to #$80 = clear timers T1 T2 and ignore them
		lda #$80							;// reset flags for timer 1 & 2, IRQset : all other flags are ignored
		jsr opl2_reg_write
		ldy opl_stat;$df60					;// get soundcard/chip status byte
		sty tmp1							;// store it
		ldx #opl2_reg_t1						;// Set timer1 to max value
		lda #$ff
		jsr opl2_reg_write
		ldx #opl2_reg_ctrl					;// set timer control byte to #$21 = mask timer2 (ignore bit1) and enable bit0 (load timer1 value and begin increment)
		lda #$21							;// this should lead to overflow (255) and setting of bits 7 and 6 in status byte (either timer expired, timer1 expired). 
		jsr opl2_reg_write
		ldy #4*clockspeed
		ldx #$ff							;// wait of loading the status byte
loc_1064C:
		dex
		bne loc_1064C
		dey
		bne loc_1064C
		lda opl_stat;$df60					;// status byte is df60 according to discussions
		and #$e0							;// and the value there with e0 (11100000, bits 7, 6 and 5) to make sure all others are 0. 
		eor #$c0							;// check if bits 7 and 6 are set (should result in 0)
		bne loc_10663						;// not zero ? jmp to set carry and leave subroutine
		tay									;// is was zero, no more a out of the way for a moment
		lda tmp1							;// read the previous status byte
		and #$e0							;// "and" that with e0, ends in zero if no bits are set
		bne loc_10663						;// was it not zero ? ok, jmp to set carry and leave
		jsr __opl2_reset_timer				;// ok previous status was no timers set. set timer control byte to #$60 = clear timers T1 T2 and ignore them
		clc									;// clear the carry flag
		jmp loc_10664						;// leave the subroutine
loc_10663:
		jsr __opl2_reset_timer
		sec									;// set the carry flag
loc_10664:						
		cli						 			;// enable interrupts
		rts

__opl2_reset_timer:
		ldx #opl2_reg_ctrl							;// ok previous status was no timers set. set timer control byte to #$60 = clear timers T1 T2 and ignore them
		lda #$60							
		jmp opl2_reg_write
			