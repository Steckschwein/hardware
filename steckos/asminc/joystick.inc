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

JOY_PORT1               = 1<<7
JOY_PORT2               = !1<<7
JOY_UP                  = 1<<0
JOY_DOWN                = 1<<1
JOY_LEFT                = 1<<2
JOY_RIGHT               = 1<<3
JOY_FIRE                = 1<<4

; UART address and registers
uart1		= $0200
uart1mcr	= uart1+4

.macro joy_off
lda #%00000100
ora uart1mcr
sta uart1mcr
.endmacro

.macro joy_on
; joysticks on
lda #%11111011
and uart1mcr
sta uart1mcr
;Port A directions
lda #%11000000 		; via port A - set PA7,6 to output (joystick port select), PA1-5 to input (directions)
sta via1ddra
.endmacro
