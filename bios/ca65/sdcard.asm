.export init_sdcard, sd_read_block
.import spi_rw_byte
.include "bios.inc"
.include "sdcard.inc"
.include "via.inc"
.segment "BIOS"

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

@l1:
		sty via1portb
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
		beq @l2

		; No Card     
		lda #$ff
		sta errno
		rts
@l2:
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

@l3:   
		lda #$ff
		phx
		jsr spi_rw_byte
		plx
		sta sd_cmd_result,x
		inx
		cpx #$05
		bne @l3

		lda sd_cmd_result
		cmp #$01
		beq @l4

		; Invalid Card (or card we can't handle yet)
		lda #$0f
		sta errno
		jsr sd_deselect_card 
		rts
@l4:       
		jsr sd_param_init
		jsr sd_busy_wait
		lda #cmd55
		jsr sd_cmd

		lda #$ff
		jsr spi_rw_byte

		cmp #$01
		beq @l5

		; Init failed
		lda #$f1      
		sta errno
		rts 

@l5:   
		jsr sd_param_init

		lda #$40
		sta sd_cmd_param

		lda #$10
		sta sd_cmd_param+1

		jsr sd_busy_wait
		lda #acmd41
		jsr sd_cmd

		lda #$ff
		jsr spi_rw_byte

		cmp #$00
		beq @l6

		cmp #$01
		beq @l4

		lda #$42
		sta errno
		rts
@l6:

		stz sd_cmd_param

		jsr sd_busy_wait

		lda #cmd58
		jsr sd_cmd

		ldx #$00

@l7:
		lda #$ff
		phx
		jsr spi_rw_byte
		plx
		sta sd_cmd_result,x
		inx
		cpx #$05
		bne @l7

		bit sd_cmd_result+1
		bvs @l8

		jsr sd_param_init

		; Set block size to 512 bytes
		lda #$02
		sta sd_cmd_param+2

		jsr sd_busy_wait

		lda #cmd16
		jsr sd_cmd

		lda #$ff
		jsr spi_rw_byte  
@l8:   
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
@l:		lda sd_cmd_param,x
		phx
		jsr spi_rw_byte
		plx
		inx
		cpx #$05
		bne @l

		; send 8 clocks with DI 1
		lda #$ff
		jsr spi_rw_byte             

		rts


;---------------------------------------------------------------------
; wait while sd card is busy
;---------------------------------------------------------------------
sd_busy_wait:

@l:		lda #$ff
		jsr spi_rw_byte
		cmp #$ff
		bne @l
		rts

;---------------------------------------------------------------------
; select sd card, pull CS line to low
;---------------------------------------------------------------------
sd_select_card:
		pha
		lda #%01111100
		sta via1portb
		pla
		rts

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
@l:		phx
		lda #$ff
		jsr spi_rw_byte
		plx
		dex
		bne @l

		plx
		pla
		rts

;---------------------------------------------------------------------
; clear sd card parameter buffer
;---------------------------------------------------------------------
sd_param_init:
		stz sd_cmd_param
		stz sd_cmd_param+1
		stz sd_cmd_param+2
		stz sd_cmd_param+3
		lda #$01
		sta sd_cmd_chksum
		; inc sd_cmd_chksum
		rts

;---------------------------------------------------------------------
; Read block from SD Card
;---------------------------------------------------------------------
; tmp0 = $f0
sd_read_block:
		jsr sd_select_card
		jsr sd_busy_wait

		; Send CMD17 command byte
		lda #cmd17
		jsr spi_rw_byte

		; Send lba_addr in reverse order
		ldx #$03
@l1:	lda lba_addr,x
		phx
		jsr spi_rw_byte
		plx
		dex
		bpl @l1

		; Send stopbit
		lda #$01
		jsr spi_rw_byte

		; wait for sd card data token
@l2:	lda #$ff
		jsr spi_rw_byte
		cmp #sd_data_token
		bne @l2

		ldy #$00
		; lda via1portb   ; Port laden
		; and #$fe        ; Takt ausschalten
		; tax             ; aufheben
		; ora #$01
		; sta tmp0

		jsr halfblock
; @l3:	lda tmp0

; 		.repeat 8
; 			STA via1portb ; Takt An 
; 			STX via1portb ; Takt aus
; 		.endrep

; 		lda via1sr
	
; 		sta (sd_blkptr),y
; 		iny
; 		bne @l3

		inc sd_blkptr+1

		jsr halfblock
; @l4:	lda tmp0

; 		.repeat 8
; 			STA via1portb ; Takt An 
; 			STX via1portb ; Takt aus
; 		.endrep

; 		lda via1sr

; 		sta (sd_blkptr),y
; 		iny
; 		bne @l4

		; dec sd_blkptr+1

		; Read CRC bytes
		lda #$ff
		jsr spi_rw_byte
		lda #$ff
		jsr spi_rw_byte

		jmp sd_deselect_card
		; rts

halfblock:
@l:		
		; lda tmp0

		; .repeat 8
		; 	STA via1portb ; Takt An 
		; 	STX via1portb ; Takt aus
		; .endrep

	
		; lda via1sr

		lda #$ff
		phy
		jsr spi_rw_byte
		ply
		sta (sd_blkptr),y
		iny
		bne @l
		rts
