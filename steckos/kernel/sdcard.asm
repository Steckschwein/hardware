.include "common.inc"
.include "kernel.inc"
.include "sdcard.inc"
.include "via.inc"
.segment "KERNEL"
.import spi_rw_byte, spi_r_byte
.export init_sdcard, sd_read_block, sd_read_multiblock, sd_write_block, sd_write_multiblock, sd_select_card, sd_deselect_card


;---------------------------------------------------------------------
; Init SD Card
; Destructive: A, X, Y
;---------------------------------------------------------------------
init_sdcard:
	; 80 Taktzyklen
	ldx #74

	; set ALL CS lines and DO to HIGH
	lda #%11111110
	sta via1portb

	tay
	iny

@l1:	sty via1portb
	sta via1portb
	dex
	bne @l1

	jsr sd_select_card

	jsr sd_param_init

	; CMD0 needs CRC7 checksum to be correct
	lda #$95
	sta sd_cmd_chksum

	; send CMD0 - init SD card to SPI mode
	lda #cmd0
	jsr sd_cmd

	; get result
	lda #$ff
	jsr spi_rw_byte

	; jsr hexout

	cmp #$01
	beq @l3

	; No Card
	lda #$ff
	sta errno
	rts

@l3:
	lda #$01
	sta sd_cmd_param+2
	lda #$aa
	sta sd_cmd_param+3
	lda #$87
	sta sd_cmd_chksum

	jsr sd_busy_wait

	lda #cmd8
	jsr sd_cmd

	ldx #$00
@l4:
	lda #$ff
	phx
	jsr spi_rw_byte
	plx
	sta sd_cmd_result,x
	inx
	cpx #$05
	bne @l4

	lda sd_cmd_result
	cmp #$01
	beq @l5

	; Invalid Card (or card we can't handle yet)
	lda #$0f
	sta errno
	jsr sd_deselect_card
	rts
@l5:

	jsr sd_param_init
	jsr sd_busy_wait
	lda #cmd55
	jsr sd_cmd

	lda #$ff
	jsr spi_rw_byte

	; jsr hexout

	cmp #$01
	beq @l6

	; Init failed
	lda #$f1
	sta errno
	rts

@l6:
	jsr sd_param_init

	lda #$40
	sta sd_cmd_param

	lda #$10
	sta sd_cmd_param+1

	jsr sd_busy_wait
	lda #acmd41
	jsr sd_cmd

	lda #$ff
	jsr spi_r_byte

	; jsr hexout

	cmp #$00
	beq @l7

	cmp #$01
	beq @l5

	lda #$42
	sta errno
	rts
@l7:

	stz sd_cmd_param

	jsr sd_busy_wait

	lda #cmd58
	jsr sd_cmd

	ldx #$00
@l8:
	lda #$ff
	phx
	jsr spi_rw_byte
	plx
	sta sd_cmd_result,x
	inx
	cpx #$05
	bne @l8

	bit sd_cmd_result+1
	bvs @l9

	jsr sd_param_init

	; Set block size to 512 bytes
	lda #$02
	sta sd_cmd_param+2

	jsr sd_busy_wait

	lda #cmd16
	jsr sd_cmd

	lda #$ff
	jsr spi_rw_byte
@l9:
	; SD card init successful
	stz errno
	rts


;---------------------------------------------------------------------
; Send SD Card Command
; cmd byte in A
; parameters in sd_cmd_param
;---------------------------------------------------------------------
sd_cmd:

		; transfer command byte
		jsr spi_rw_byte

		; transfer parameter buffer
		ldx #$00
@l1: 	lda sd_cmd_param,x
		phx
		jsr spi_rw_byte
		plx
		inx
		cpx #$05
		bne @l1

		; send 8 clocks with DI 1
		lda #$ff
		jsr spi_rw_byte

		rts

;---------------------------------------------------------------------
; Send SD Card block Command
; cmd byte in A
; block lba in lba_addr
;---------------------------------------------------------------------
sd_block_cmd:
		;lda #cmd18	; Send CMD18 command byte
		jsr spi_rw_byte

		jsr sd_send_lba

		; Send stopbit
		lda #$01
		jmp spi_rw_byte


sd_wait_timeout:
		stz errno
        	ldy #sd_cmd_response_retries 	; wait for command response.
		stz krn_tmp				; use krn_tmp as loop var, not needed here
@l:		jsr spi_r_byte
        	beq @x
		dec krn_tmp
		bne @l
        	dey
		bne @l
		sta errno
        	;TODO FIXME error sd error codes
@x:
		rts

;---------------------------------------------------------------------
; Read block from SD Card
;---------------------------------------------------------------------
sd_read_block:
        stz errno
		jsr sd_select_card

		lda #cmd17
		jsr sd_block_cmd
;		jsr spi_rw_byte         ; send CMD17 command byte
;		jsr sd_send_lba         ; send 32 Bit block address

		; Send stopbit
;		lda #$01                ; send "crc" and stop bit
;		jsr spi_rw_byte

		jsr sd_wait_timeout
		lda errno
       	bne @exit
@l1:


;		ldy #$00

;		jsr halfblock

;		inc read_blkptr+1
;		jsr halfblock
;;		dec read_blkptr+1

;		jsr spi_r_byte		; Read 2 CRC bytes
;		jsr spi_r_byte

		jsr fullblock

@exit: ; fall through to sd_deselect_card


		;---------------------------------------------------------------------
		; deselect sd card, puSH CS line to HI and generate few clock cycles
		; to allow card to deinit
		;---------------------------------------------------------------------
sd_deselect_card:
			pha
			phx
			; set CS line to HI
			lda #%01111110
			sta via1portb

			ldx #$04
		@l1:
			phx
			jsr spi_r_byte
			plx
			dex
			bne @l1
			plx
			pla
			rts

fullblock:
		; wait for sd card data token
		jsr sd_wait_data_token
		ldy #$00
		jsr halfblock

		inc read_blkptr+1
		jsr halfblock
		;		dec read_blkptr+1

		jsr spi_r_byte		; Read 2 CRC bytes
		jmp spi_r_byte
		;rts

halfblock:
@l:
		jsr spi_r_byte
		sta (read_blkptr),y
		iny
		bne @l
		rts

;---------------------------------------------------------------------
; Read multiple blocks from SD Card
;---------------------------------------------------------------------
sd_read_multiblock:
		save

		jsr sd_select_card

		lda #cmd18	; Send CMD18 command byte
		jsr sd_block_cmd
		; wait for command response.
		jsr sd_wait_timeout
		lda errno
    	beq @l1
		bra @exit
@l1:
;		jsr sd_wait_data_token

;		ldy #$00
;		lda via1portb   ; Port laden
;		and #$fe        ; Takt ausschalten
;		tax             ; aufheben
;		ora #$01
;		sta sd_tmp


		jsr fullblock
		inc read_blkptr+1

;		lda sd_tmp
	; Read CRC bytes
;	.repeat 16
;		sta via1portb ; Takt An
;		stx via1portb ; Takt aus
;	.endrepeat

		dec blocks
		beq @l3
		bra @l1
@l3:
		jsr sd_busy_wait

        ; all blocks read, send cmd12 to end transmission
        ; jsr sd_param_init
        lda #cmd12
        jsr sd_cmd

        jsr sd_busy_wait
@exit:
        restore
        jmp sd_deselect_card

;---------------------------------------------------------------------
; Write block to SD Card
;---------------------------------------------------------------------
sd_write_block:
	save
	jsr sd_select_card

	lda #cmd24
	jsr sd_block_cmd

	jsr sd_wait_timeout
	lda errno
        bne @exit
;@l1:
    	;lda #$ff
	;jsr spi_rw_byte
	;bne @l1

	lda #sd_data_token
	jsr spi_rw_byte

	ldy #$00
@l2:	lda (write_blkptr),y
	phy
	jsr spi_rw_byte
	ply
	iny
	bne @l2

	inc write_blkptr+1

	ldy #$00
@l3:	lda (write_blkptr),y
	phy
	jsr spi_rw_byte
	ply
	iny
	bne @l3

	; Send fake CRC bytes
	lda #$00
	jsr spi_rw_byte
	lda #$00
	jsr spi_rw_byte
	inc write_blkptr+1
@exit:
        restore
        jmp sd_deselect_card

;---------------------------------------------------------------------
; Write multiple blocks to SD Card
;---------------------------------------------------------------------
sd_write_multiblock:
	save

	jsr sd_select_card

	lda #cmd25	; Send CMD25 command byte
	jsr sd_block_cmd

	; wait for command response.
	jsr sd_wait_timeout
	lda errno
       	bne @exit

@block:
	lda #sd_data_token
	jsr spi_rw_byte

	ldy #$00
@l2:	lda (write_blkptr),y
	phy
	jsr spi_rw_byte
	ply
	iny
	bne @l2

	inc write_blkptr+1

	ldy #$00
@l3:	lda (write_blkptr),y
	phy
	jsr spi_rw_byte
	ply
	iny
	bne @l3

	; Send fake CRC bytes
	lda #$00
	jsr spi_rw_byte
	lda #$00
	jsr spi_rw_byte

	dec blocks
	bne @block

        ; all blocks read, send cmd12 to end transmission
        ; jsr sd_param_init
        lda #cmd12
        jsr sd_cmd

        jsr sd_busy_wait

@exit:
	restore
	rts
;---------------------------------------------------------------------
; wait while sd card is busy
;---------------------------------------------------------------------
sd_busy_wait:
@l1:    lda #$ff
        jsr spi_rw_byte
        cmp #$ff
        bne @l1
        ;TODO FIXME
  ;      lda #$fa
   ;     sta errno
@l2:
        rts

;---------------------------------------------------------------------
; wait for sd card data token
;---------------------------------------------------------------------
sd_wait_data_token:
		ldy #sd_data_token_retries
		stz	krn_tmp				; use krn_tmp as loop var, not needed here
@l1:
		jsr spi_r_byte
		cmp #sd_data_token
		beq @l2
		dec	krn_tmp
		bne	@l1
		dey
		bne @l1
		;TODO FIXME check card state here, may be was removed
;       lda #$e0
        sta errno
@l2:	rts

;---------------------------------------------------------------------
; select sd card, pull CS line to low
;---------------------------------------------------------------------
sd_select_card:
	lda #sd_card_sel
	sta via1portb
	bra sd_busy_wait



;---------------------------------------------------------------------
; clear sd card parameter buffer
;---------------------------------------------------------------------
sd_param_init:
		ldx #$03
@l:
		stz sd_cmd_param,x
		dex
		bpl @l
		lda #$01
		sta sd_cmd_chksum
		rts

sd_send_lba:
		; Send lba_addr in reverse order
		ldx #$03
@l:
		lda lba_addr,x
		phx
		jsr spi_rw_byte
		plx
		dex
		bpl @l
		rts
