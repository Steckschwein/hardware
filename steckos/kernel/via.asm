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
.segment "KERNEL"
.export init_via1
.include "via.inc"

;----------------------------------------------------------------------------------------------
; init VIA1 - set all ports to input
;----------------------------------------------------------------------------------------------
init_via1:

		; disable VIA1 interrupts
		lda #%01111111          ; bit 7 "0", to clear all int sources
		sta via1ier

		;Port A directions
		lda #%11000000 		; via port A - set PA7,6 to output (joystick port select), PA1-5 to input (directions)
		sta via1ddra

		; init shift register and port b for SPI use
		; SR shift in, External clock on CB1
		lda #%00001100
		sta via1acr

		; Port b bit 6 and 5 input for sdcard and write protect detection, rest all outputs
		lda #%10011111
		sta via1ddrb

		; SPICLK low, MOSI low, SPI_SS HI
		lda #%01111110
		sta via1portb

		rts
;----------------------------------------------------------------------------------------------
