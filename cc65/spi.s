;
;
; int spi_read (char *c);
;
        .export         _spi_read
        .export         _spi_write
_spi_read: 
        jsr $ff0c
	ldx #$00
	rts
_spi_write: 
        jsr $ff09
