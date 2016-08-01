.include "kernel.inc"
.segment "KERNEL"
.export init_via1
.include "via.inc"

;----------------------------------------------------------------------------------------------
; init VIA1 - set all ports to input
;----------------------------------------------------------------------------------------------
init_via1:

			; disable VIA1 interrupts
;			lda #$00
            lda #%01111111          ; bit 7 "0", to clear all int sources
			sta via1ier             
 
            ;Port A directions
            lda #%11000000 			; via port A - set PA7,6 to output (joystick port select), PA1-5 to input (directions)
            sta via1ddra 		 	

			; init shift register and port b for SPI use
			; SR shift in, External clock on CB1
			lda #%00001100
			sta via1acr

			; Port b bit 5and 6 input for sdcard and write protect detection, rest all outputs
			lda #%10011111
			sta via1ddrb

			; SPICLK low, MOSI low, SPI_SS HI
			lda #%01111110
			sta via1portb

		 	rts
;----------------------------------------------------------------------------------------------