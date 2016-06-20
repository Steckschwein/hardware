.include "kernel.inc"
.include "via.inc"
.import spi_rw_byte
.export init_rtc
.segment "KERNEL"
init_rtc:
	; disable RTC interrupts
	; Select SPI SS for RTC
	lda #%01110110
	; and via1portb
	sta via1portb

    lda #$8f
    jsr spi_rw_byte
	lda #$00
    jsr spi_rw_byte

	; Select SPI SS for RTC
	lda #%01111110
	; and via1portb
	sta via1portb
	rts