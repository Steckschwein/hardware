;
;
; unsigned char _spi_read ();
;
        .export         _spi_read
        .export         _spi_write
		
_spi_read:
        jsr $ff0c
		ldx #$00
		rts
		
_spi_write:
        jsr $ff09
		ldx #$00
		rts		
