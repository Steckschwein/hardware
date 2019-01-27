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

.include "kernel.inc"
.include "via.inc"
.import spi_r_byte, spi_deselect, spi_select_device
.export getkey
.segment "KERNEL"

spi_device_keyboard=%01111010

; Select Keyboard controller on SPI, get byte from buffer
;	in:	-
;	out:
;		C=1 key was pressed and A= <key code>, C=0 otherwise
getkey:
		lda #spi_device_keyboard
		jsr spi_select_device
		bne @l1

		phx

		jsr spi_r_byte

		jsr spi_deselect

		plx

		cmp #$00
		beq @l1
		sec
		rts
@l1:
		clc
		rts
