.include "kernel.inc"
.include "via.inc"
.import spi_rw_byte, spi_deselect
.export init_rtc, spi_select_rtc

.segment "KERNEL"

spi_device_rtc=$76;#%01110110

spi_select_rtc:
	lda #spi_device_rtc
	; and via1portb
	sta via1portb
	rts

init_rtc:
	; disable RTC interrupts
	; Select SPI SS for RTC
	lda #spi_device_rtc
	; and via1portb
	sta via1portb

	lda #$8f
	jsr spi_rw_byte
	lda #$00
	jsr spi_rw_byte

	; Deselect SPI SS for RTC
	jsr	spi_deselect
	rts