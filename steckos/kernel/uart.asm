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
.export  init_uart, uart_tx, uart_rx, uart_rx_nowait
.include "uart.inc"
.segment "KERNEL"

;----------------------------------------------------------------------------------------------
; init UART
;----------------------------------------------------------------------------------------------
init_uart:
;		lda #%10000000
;		sta uart1lcr

		; 115200 baud0
;		lda #$01
		; 19200 baud
;		lda #$06
;		sta uart1dll
;		stz uart1dlh

		; 8N1
;		lda #%00000011
;		sta uart1lcr

		lda #%00000111	; Enable FIFO, reset tx/rx FIFO
		sta uart1fcr

		stz uart1ier	; polled mode (so far)
		stz uart1mcr	; reset DTR, RTS

		rts
;----------------------------------------------------------------------------------------------

;----------------------------------------------------------------------------------------------
; send byte in A
;----------------------------------------------------------------------------------------------
uart_tx:
		pha

		lda #$20
@l:
		bit uart1lsr
		beq @l

		pla

		sta uart1rxtx

		rts
;----------------------------------------------------------------------------------------------

;----------------------------------------------------------------------------------------------
; receive byte, wait until received, store in A
;----------------------------------------------------------------------------------------------
uart_rx:
		lda #$01        ; Maske fuer DataReady Bit
@l:
		bit uart1lsr
		beq @l
		lda uart1rxtx
		rts
;----------------------------------------------------------------------------------------------

;----------------------------------------------------------------------------------------------
; receive byte, no wait, set carry and store in A when received
;----------------------------------------------------------------------------------------------
uart_rx_nowait:
                lda #$01        ; Maske fuer DataReady Bit
                bit uart1lsr
                beq @l
                lda uart1rxtx
                sec
                rts
@l:
                clc
                rts
;----------------------------------------------------------------------------------------------
