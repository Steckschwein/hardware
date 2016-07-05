.include "kernel.inc"
.include "sdcard.inc"
.include "via.inc"
tmp = $00
.segment "KERNEL"
.import spi_rw_byte, spi_r_byte
.export init_sdcard, sd_read_block, sd_read_multiblock, sd_write_block

;---------------------------------------------------------------------
; check sd card presence and state of the read only switch
; set appropriate bits in sd_card_status
;---------------------------------------------------------------------
sd_check_card_status:
	lda via1portb
	and #%01100000
	asl

	sta sd_card_status
	rts

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

@l1:   sty via1portb
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
@l1:   lda sd_cmd_param,x
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
; Read block from SD Card
;---------------------------------------------------------------------
sd_read_block:
	jsr sd_select_card
	jsr sd_busy_wait
	
	; Send CMD17 command byte
	lda #cmd17
	jsr spi_rw_byte

	jsr sd_send_lba
	
	; Send stopbit
	lda #$01
	jsr spi_rw_byte

	; wait for sd card data token
@l1:   jsr spi_r_byte                         
	cmp #sd_data_token
	bne @l1

	ldy #$00
	lda via1portb   ; Port laden
	AND #$fe        ; Takt ausschalten
	TAX             ; aufheben
	ORA #$01
	sta tmp0

@l2:   lda tmp0

	.repeat 8
		STA via1portb ; Takt An 
		STX via1portb ; Takt aus
	.endrepeat

	lda via1sr
	sta (sd_blkptr),y
	iny
	bne @l3

	inc sd_blkptr+1

@l3:   lda tmp0

	.repeat 8
		STA via1portb ; Takt An 
		STX via1portb ; Takt aus
	.endrepeat
	lda via1sr

	sta (sd_blkptr),y
	iny
	bne @l3

	; dec sd_blkptr+1

	; Read CRC bytes 
	.repeat 16    
		STA via1portb ; Takt An 
		STX via1portb ; Takt aus
	.endrepeat

	jmp sd_deselect_card
	; rts

;---------------------------------------------------------------------
; Read multiple blocks from SD Card
;---------------------------------------------------------------------
sd_read_multiblock:
	save

	jsr sd_select_card

	; Send CMD18 command byte
	jsr sd_busy_wait  

	lda #cmd18
	jsr spi_rw_byte

	jsr sd_send_lba

	; Send stopbit
	lda #$01
	jsr spi_rw_byte

	; Wait for data token
@l1:   jsr spi_r_byte             
	cmp #$fe
	bne @l1

	ldy #$00
	lda via1portb   ; Port laden
	AND #$fe        ; Takt ausschalten
	TAX             ; aufheben
	ORA #$01
	sta tmp0
 
	; read 256 bytes twice, increase blkptr in between

	

@l2a:	lda tmp0

	.repeat 8
		STA via1portb ; Takt An 
		STX via1portb ; Takt aus
	.endrepeat

	lda via1sr
	sta (sd_blkptr),y
	iny
	bne @l2a

	inc sd_blkptr+1             

@l2b:	lda tmp0

	.repeat 8
		STA via1portb ; Takt An 
		STX via1portb ; Takt aus
	.endrepeat

	lda via1sr
	sta (sd_blkptr),y
	iny
	bne @l2b

	inc sd_blkptr+1             


		
	lda tmp0
	; Read CRC bytes     
	.repeat 16    
		STA via1portb ; Takt An 
		STX via1portb ; Takt aus
	.endrepeat

   
	dec <blocks
	beq @l3
	jmp @l1
@l3:
		
	jsr sd_busy_wait  

	; all blocks read, send cmd12 to end transmission
	; jsr sd_param_init
	lda #cmd12
	jsr sd_cmd

	jsr sd_busy_wait  
	
	restore
	jmp sd_deselect_card
	; rts

;---------------------------------------------------------------------
; Write block to SD Card
;---------------------------------------------------------------------
sd_write_block:
	jsr sd_select_card

	jsr sd_busy_wait

	lda #cmd24
	jsr sd_cmd
	
@l1:	lda #$ff
	jsr spi_rw_byte             
	bne @l1

	lda #$fe
	jsr spi_rw_byte

	ldy #$00
@l2:	lda (sd_blkptr),y
	phy
	jsr spi_rw_byte
	ply
	iny
	bne @l2

	inc sd_blkptr+1

	ldy #$00
@l3:	lda (sd_blkptr),y
	phy
	jsr spi_rw_byte
	ply
	iny
	bne @l3
	dec sd_blkptr+1

	; Send fake CRC bytes
	lda #$00
	jsr spi_rw_byte
	lda #$00
	jsr spi_rw_byte

	jmp spi_r_byte              
	;rts   

;---------------------------------------------------------------------
; wait while sd card is busy
;---------------------------------------------------------------------
sd_busy_wait:
@l1:	lda #$ff
	jsr spi_rw_byte
	cmp #$ff
	bne @l1
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
@l1:      
	; lda #$ff
	phx
	jsr spi_rw_byte
	plx
	dex
	bne @l1
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
	stz sd_cmd_chksum
	inc sd_cmd_chksum
	rts

sd_send_lba:
	; Send lba_addr in reverse order

	lda lba_addr + 0
	jsr spi_rw_byte
	lda lba_addr + 1
	jsr spi_rw_byte
	lda lba_addr + 2
	jsr spi_rw_byte
	lda lba_addr + 3
	jsr spi_rw_byte
	
	rts