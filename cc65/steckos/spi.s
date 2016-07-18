;
;
; unsigned char _spi_read ();
;
        .export         _spi_read
        .export         _spi_write

		.include        "../../steckos/kernel/ca65/kernel_jumptable.inc"
		
_spi_read:
        jsr krn_spi_r_byte
		ldx #$00
		rts
		
_spi_write:
        jsr krn_spi_rw_byte
		ldx #$00
		rts		
