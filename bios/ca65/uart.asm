.setcpu "65c02"
.export init_uart, uart_tx, uart_rx
.include "bios.inc"
.segment "BIOS"

;----------------------------------------------------------------------------------------------
; init UART
;----------------------------------------------------------------------------------------------
init_uart:
			lda #%10000000
			sta uart1lcr


			ldy #param_uart_div	
			lda (paramvec),y
			sta uart1dll	

			iny
			lda (paramvec),y
			sta uart1dlh	

			; ; $0001 , 115200 baud
			; lda #$01
			; sta uart1dll	
			; stz uart1dlh

			ldy #param_lsr  
			lda (paramvec),y
			sta uart1lcr

			; lda #$00
			stz uart1fcr	; FIFO off
			stz uart1ier	; polled mode (so far) 
			stz uart1mcr	; reset DTR, RTS

			and #%00001100			; keep OUT1, OUT2 values
			sta uart1mcr		; reset DTR, RTS
			; clc

			rts

;----------------------------------------------------------------------------------------------
; send byte in A 
;----------------------------------------------------------------------------------------------
uart_tx:
			pha

@l:			
			lda uart1lsr
			and #$20
			beq @l

			pla 

			sta uart1rxtx

			rts

;----------------------------------------------------------------------------------------------
; receive byte, store in A 
;----------------------------------------------------------------------------------------------
uart_rx:
@l:		
			lda uart1lsr 
			and #$1f
			cmp #$01
			bne @l
			
			lda uart1rxtx
		 
			rts

;----------------------------------------------------------------------------------------------
