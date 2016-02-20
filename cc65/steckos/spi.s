;
;
; unsigned char _spi_read ();
;
        .export         _spi_read
        .export         _spi_write

        .include         "../../bios/bios.inc"
		
_spi_read:
        jsr bios_spi_r_byte
		ldx #$00
		rts
		
_spi_write:
        jsr bios_spi_rw_byte
		ldx #$00
		rts		
