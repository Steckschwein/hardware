.include "kernel.inc"
.export  init_uart, uart_tx, uart_rx
.include "uart.inc"
.segment "KERNEL"

;----------------------------------------------------------------------------------------------
; init UART
;----------------------------------------------------------------------------------------------
init_uart:
		lda #%10000000
		sta uart1lcr
			
		; 115200 baud
		lda #$01
		; 19200 baud
;		lda #$06
		sta uart1dll	
		stz uart1dlh

		; 8N1
		lda #%00000011
		sta uart1lcr

		lda #%00000111	; Enable FIFO, reset tx/rx FIFO
		sta uart1fcr	

		stz uart1ier	; polled mode (so far) 
		stz uart1mcr	; reset DTR, RTS

		rts

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
; receive byte, store in A 
;----------------------------------------------------------------------------------------------
uart_rx:
		lda #$01        ; Maske fuer DataReady Bit
@l:
		bit uart1lsr
		beq @l
		lda uart1rxtx
		rts
;----------------------------------------------------------------------------------------------
