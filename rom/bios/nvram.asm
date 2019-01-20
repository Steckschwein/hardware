.export read_nvram
.import spi_rw_byte, print_crlf, primm, set_filenameptr
.include "bios.inc"
.include "via.inc"
.segment "BIOS"

;---------------------------------------------------------------------
; read 96 bytes from RTC as parameter buffer
;---------------------------------------------------------------------
read_nvram:
	save
	; select RTC
	lda #%01110110
	sta via1portb

	lda #$20
	jsr spi_rw_byte

	ldx #$00
@l1:	
	phx
	lda #$ff
	jsr spi_rw_byte
	plx
	sta nvram,x
	inx
	cpx #96
	bne @l1

	; deselect all SPI devices
	lda #%01111110
	sta via1portb


	lda #$42
	cmp nvram + param_sig
	bne @invalid_sig

	SetVector nvram, paramvec
	jsr set_filenameptr

@exit:
	restore
	rts
@invalid_sig:
	printlnstring "NVRAM: Invalid signature."
	bra @exit
; .nvram_crc_error
; 	+PrintString .txt_nvram_crc_error
; 	bra -
