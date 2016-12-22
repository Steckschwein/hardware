.include "kernel.inc"
.export  init_uart, uart_tx, uart_rx
; .import vdp_chrout, print_crlf, hexout, primm
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
		sta uart1dll	
		stz uart1dlh

		; 8N1
		lda #%00000011
		sta uart1lcr

		lda #$01	; Enable FIFO
		sta uart1fcr	

		stz uart1ier	; polled mode (so far) 
		stz uart1mcr	; reset DTR, RTS

		and #%00001100	; keep OUT1, OUT2 values
		sta uart1mcr	; reset DTR, RTS

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

; upload:
; 		jsr print_crlf
; 		printstring "Serial upload.."
; 		; load start address
; 		jsr uart_rx
; 		sta startaddr
		
; 		jsr uart_rx
; 		sta startaddr+1


; 		; lda startaddr+1
; 		jsr hexout
; 		lda startaddr
; 		jsr hexout

; 		lda #' '
; 		jsr vdp_chrout

; 		jsr upload_ok

; 		; load number of bytes to be uploaded
; 		jsr uart_rx
; 		sta length
			
; 		jsr uart_rx
; 		sta length+1

; 		; calculate end address
; 		clc
; 		lda length
; 		adc startaddr
; 		sta endaddr

; 		lda length+1
; 		adc startaddr+1
; 		sta endaddr+1

; 		; lda endaddr+1
; 		jsr hexout

; 		lda endaddr
; 		jsr hexout
		
; 		lda #' '
; 		jsr vdp_chrout
		

; 		lda startaddr
; 		sta addr
; 		lda startaddr+1
; 		sta addr+1	

; 		jsr upload_ok

; 		ldy #$00
; @l1:
; 		jsr uart_rx
; 		sta (addr),y

; 		iny	
; 		cpy #$00
; 		bne @l2
; 		inc addr+1

; @l2:		
; 		; msb of current address equals msb of end address?
; 		lda addr+1
; 		cmp endaddr+1
; 		bne @l1 ; no? read next byte

; 		; yes? compare y to lsb of endaddr
; 		cpy endaddr
; 		bne @l1 ; no? read next byte

; 		; yes? write OK 

; 		jsr upload_ok

; 		printstring "OK"
; 		rts

; upload_ok:
; 		lda #'O'
; 		jsr uart_tx
; 		lda #'K'
; 		jmp uart_tx
; 		; rts
