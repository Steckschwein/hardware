;
; extern void __fastcall__ spi_select(SpiDevice d);
;
_spi_select:
	

	rts

;	
_spi_deselect = krn_spi_deselect

;
;
; unsigned char _spi_read ();
;
        .export         _spi_read
        .export         _spi_write
        .export         _spi_deselect
        .export         _spi_select
        
		.include		"../kernel/kernel_jumptable.inc"
		
_spi_read:
        jsr krn_spi_r_byte
        ;pha
 ;       jsr krn_hexout
 ;       pla
		ldx #$00
		rts
		
_spi_write:
        jsr krn_spi_rw_byte
		ldx #$00              ; low byte in A, clean high byte
        pha
;        jsr krn_hexout
        pla
		rts		
