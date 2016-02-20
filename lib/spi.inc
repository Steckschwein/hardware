    .include        "../../lib/via.inc"

; deselect any device
spi_device_deselect=$7e

spi_deselect:
    lda #spi_device_deselect
spi_select:
	sta via1portb
    rts


