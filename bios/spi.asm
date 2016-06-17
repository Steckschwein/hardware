.setcpu "65c02"
.segment "BIOS"
.export spi_rw_byte
.include "bios.inc"
.include "via.inc"

;----------------------------------------------------------------------------------------------
; Transmit byte VIA SPI
; Byte to transmit in A, received byte in A at exit
; Destructive: A,X,Y
;----------------------------------------------------------------------------------------------

spi_rw_byte:
		sta tmp0	; zu transferierendes byte im akku nach tmp0 retten

		ldx #$08
		
		lda via1portb	; Port laden
		and #$fe        ; SPICLK loeschen

		asl		; Nach links rotieren, damit das bit nachher an der richtigen stelle steht
		tay		 ; bunkern

@l:
		rol tmp0
		tya		; portinhalt
		ror		; datenbit reinschieben

		sta via1portb	; ab in den port
		inc via1portb	; takt an
		sta via1portb	; takt aus 

		dex
		bne @l		; schon acht mal?
		
		lda via1sr	; Schieberegister auslesen

		rts
