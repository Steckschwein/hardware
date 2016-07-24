.include "kernel.inc"
.include "via.inc"

.segment "KERNEL"
.export spi_rw_byte, spi_r_byte, spi_deselect

spi_device_deselect=$7e		; deselect any device

spi_deselect:
    lda #spi_device_deselect
spi_select:
	sta via1portb
    rts
 	

;----------------------------------------------------------------------------------------------
; Transmit byte VIA SPI
; Byte to transmit in A, received byte in A at exit
; Destructive: A,X,Y
;----------------------------------------------------------------------------------------------
spi_rw_byte:
		sta spitmp	; zu transferierendes byte im akku nach tmp0 retten

		ldx #$08
		
		lda via1portb	; Port laden
		and #$fe        ; SPICLK loeschen

		asl		; Nach links rotieren, damit das bit nachher an der richtigen stelle steht
		tay		 ; bunkern

@l:
		rol spitmp
		tya		; portinhalt
		ror		; datenbit reinschieben

		sta via1portb	; ab in den port
		inc via1portb	; takt an
		sta via1portb	; takt aus 

		dex
		bne @l		; schon acht mal?
		
		lda via1sr	; Schieberegister auslesen

		rts

;----------------------------------------------------------------------------------------------
; Receive byte VIA SPI
; Received byte in A at exit
; Destructive: A,X
;----------------------------------------------------------------------------------------------
spi_r_byte:
       lda via1portb   ; Port laden
       AND #$fe        ; Takt ausschalten
       TAX             ; aufheben
       ORA #$01

       STA via1portb ; Takt An 1
       STX via1portb ; Takt aus
       STA via1portb ; Takt An 2
       STX via1portb ; Takt aus
       STA via1portb ; Takt An 3
       STX via1portb ; Takt aus
       STA via1portb ; Takt An 4
       STX via1portb ; Takt aus
       STA via1portb ; Takt An 5
       STX via1portb ; Takt aus
       STA via1portb ; Takt An 6
       STX via1portb ; Takt aus
       STA via1portb ; Takt An 7
       STX via1portb ; Takt aus
       STA via1portb ; Takt An 8
       STX via1portb ; Takt aus

       lda via1sr
       rts