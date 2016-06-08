.setcpu "65c02"
.include "bios.inc"
; Address pointers for serial upload
startaddr	= ptr1
endaddr		= ptr2
length		= $e0

DPL 		= $00
DPH 		= $01
	
.segment "CHAR"
charset:
.include "charset_ati_8x8.h.asm"

.segment "BIOS"

.macro SetVector word, addr 
			lda #<word
			sta addr
			lda #>word
			sta addr+1
.endmacro

.macro	printstring text
			jsr primm
			.asciiz text
.endmacro


do_reset:
			; disable interrupt
			sei

			; clear decimal flag
			cld

			; init stack pointer
			ldx #$ff
			txs

   			; Check zeropage and Memory
check_zp:
		    ; Start at $ff
			ldy #$ff
			; Start with pattern $03 : $ff
@l2:		ldx #num_patterns
@l1:		lda pattern,x
			sta $00,y
			cmp $00,y
			bne zp_broken

			dex
			bne @l1

			dey
			bne @l2

check_stack:
			;check stack
			ldy #$ff
@l2:		ldx #num_patterns
@l1:		lda pattern,x
			sta $0100,y
			cmp $0100,y
			bne stack_broken

			dex
			bne @l1

			dey
			bne @l2

check_memory:
			lda #>start_check
			sta ptr1h
			ldy #<start_check
			stz ptr1l

@l2:		ldx #num_patterns  ; 2 cycles
@l1:		lda pattern,x      ; 4 cycles
	  		sta (ptr1l),y   ; 6 cycles
			cmp (ptr1l),y   ; 5 cycles
			bne @l3				  ; 2 cycles, 3 if taken

			dex  				  ; 2 cycles
			bne @l1			  ; 2 cycles, 3 if taken

			iny  				  ; 2 cycles		
			bne @l2				  ; 2 cycles, 3 if taken

			; Stop at $e000 to prevent overwriting BIOS Code when ROMOFF
			ldx ptr1h		  ; 3 cycles
			inx				  ; 2 cycles
			stx ptr1h		  ; 3 cycles
			cpx #$e0			  ; 2 cycles

			bne @l2 			  ; 2 cycles, 3 if taken
@l3:  		sty ptr1l		  ; 3 cycles
		
	  					  ; 42 cycles

	  		; save end address
	  		lda ptr1l
	  		sta ram_end_l
	  		lda ptr1h
	  		sta ram_end_h
	  		
	  	   

			bra mem_ok

mem_broken:
			lda #$40
			sta $0230
@loop:		jmp @loop

zp_broken:
			lda #$80
			sta $0230
@loop:		jmp @loop

stack_broken:
			lda #$40
			sta $0230
@loop:		jmp @loop


mem_ok:
		
			jsr init_vdp

			printstring "bios     20160608"
			jsr print_crlf
			printstring "memcheck $"
			lda ram_end_h
			jsr hexout
			lda ram_end_l
			jsr hexout

			jsr init_via1
			jsr init_uart

			jsr init_sdcard
			lda errno
			beq boot_from_card
			; display sd card error message

			jsr upload
			jmp startup

boot_from_card:
			printstring "boot from card"
end:		jmp end			
			; load fat and stuff
		; re-init stack pointer
startup:
			ldx #$ff
			txs

			; jump to new code
			jmp (startaddr)

;----------------------------------------------------------------------------------------------
; init UART
;----------------------------------------------------------------------------------------------
init_uart:
			lda #%10000000
			sta uart1lcr

			; $0001 , 115200 baud
			lda #$01
			sta uart1dll	
			stz uart1dlh

			lda #%00000011	; 8N1

			sta uart1lcr

			lda #$00
			sta uart1fcr	; FIFO off
			sta uart1ier	; polled mode (so far) 
			sta uart1mcr	; reset DTR, RTS

			and #%00001100			; keep OUT1, OUT2 values
			sta uart1mcr		; reset DTR, RTS
			; clc

			rts

;----------------------------------------------------------------------------------------------
; send byte in A 
;----------------------------------------------------------------------------------------------
uart_tx:
			pha

@l:			
			lda uart1lsr
			and #$20
			beq @l

			pla 

			sta uart1rxtx

			rts

;----------------------------------------------------------------------------------------------
; receive byte, store in A 
;----------------------------------------------------------------------------------------------
uart_rx:
@l:		
			lda uart1lsr 
			and #$1f
			cmp #$01
			bne @l
			
			lda uart1rxtx
		 
			rts

;----------------------------------------------------------------------------------------------

;----------------------------------------------------------------------------------------------
; init VIA1 - set all ports to input
;----------------------------------------------------------------------------------------------
init_via1:

			; disable VIA1 interrupts
			lda #$00
			sta via1ier             

			; init shift register and port b for SPI use
			; SR shift in, External clock on CB1
			lda #%00001100
			sta via1acr

			; Port b bit 5and 6 input for sdcard and write protect detection, rest all outputs
			lda #%10011111
			sta via1ddrb

			; SPICLK low, MOSI low, SPI_SS HI
			lda #%01111110
			sta via1portb
		 	
		 	rts
;----------------------------------------------------------------------------------------------

;----------------------------------------------------------------------------------------------
; init tms9929 into gfx1 mode
;----------------------------------------------------------------------------------------------

.macro	vnops
			jsr vnopslide
			; nop
			; nop
			; nop
			; nop
			; nop
			; nop
			; nop
			; nop
			; nop
			; nop
			; nop
			; nop
.endmacro

.macro	SyncBlank
    		lda a_vreg
@lada:	
			bit	a_vreg
			bpl @lada	   ; wait until blank - irq flag set?
.endmacro

.macro vdp_sreg 
			sta	a_vreg
			vnops
			sty	a_vreg	
.endmacro

init_vdp:
			;display off
			lda		#v_reg1_16k	;enable 16K ram, disable screen
			ldy	  	#v_reg1
			vdp_sreg
			SyncBlank

			lda	#<ADDRESS_GFX_SPRITE
			ldy	#WRITE_ADDRESS + >ADDRESS_GFX_SPRITE
			vdp_sreg
			lda	#$d0					;sprites off, at least y=$d0 will disable the sprite subsystem
			vnops
			vnops
			sta a_vram

			lda	#<ADDRESS_GFX1_SCREEN
			ldy	#WRITE_ADDRESS + >ADDRESS_GFX1_SCREEN
			vdp_sreg
			ldy   #$00      ;2
			ldx	#$03                    ;3 pages - 3x256 byte
			lda	#' '					;fill vram screen with blank
@l1: 
			vnops          ;8
			; nop             
			; nop
			iny             ;2
			sta   a_vram    ;
			bne   @l1        ;3
			dex
			bne   @l1

			stz crs_x
			stz crs_y

			lda #<ADDRESS_GFX1_PATTERN
			ldy #WRITE_ADDRESS + >ADDRESS_GFX1_PATTERN
			vdp_sreg
			ldx #$08                    ;load charset
			ldy   #$00     ;2
			SetVector    charset, addr
@l2:
			lda   (addr),y ;5
			iny            ;2
			vnops         ;8
			sta   a_vram   ;1 opcode fetch	
			bne   @l2        ;3
			inc   adrh
			dex
			bne   @l2

			lda	#<ADDRESS_GFX1_COLOR
			ldy	#WRITE_ADDRESS + >ADDRESS_GFX1_COLOR	;color vram
			vdp_sreg
			lda #Gray<<4|Black          ;enable gfx 1 with cyan on black background
			ldx	#$20
@l3:
			vnops      ;8
			; nop
			; nop
			dex         ;2
			sta a_vram  ;
			bne @l3       ;3

			ldx	#$00
			ldy	#v_reg0
@l4:
			lda vdp_init_bytes_gfx1,x
			vdp_sreg
			iny
			inx
			cpx	#$08
			bne @l4
			rts



; foo = ADDRESS_GFX1_SCREEN+(WRITE_ADDRESS<<8)
vdp_scroll_up:
			SetVector	ADDRESS_GFX1_SCREEN+COLS, ptr1		        ; +.COLS - offset second row
			SetVector	(ADDRESS_GFX1_SCREEN+(WRITE_ADDRESS<<8)), ptr2	; offset first row

			lda	a_vreg  ; clear v-blank bit, we dont know where we are...
@l1:
			bit	a_vreg  ; sync with next v-blank, so that we have the full 4,3µs
			bpl	@l1
@l2:
		lda	ptr1l	; 3cl
		sta	a_vreg
		lda	ptr1h	; 3cl
		sta	a_vreg
		; nop			; wait 2µs, 4Mhz = 8cl => 4 nop
		; nop			; 2cl
		; nop			; 2cl
		; nop			; 2cl
		vnops

		ldx	a_vram	;
		; nop			; 2cl
		; nop			; 2cl
		; nop			; 2cl
		; nop			; 2cl
		vnops
		lda	ptr2l	; 3cl
		sta	a_vreg
		lda	ptr2h	; 3cl
		sta a_vreg
		; nop			; 2cl
		; nop			; 2cl
		; nop			; 2cl
		; nop			; 2cl
		vnops
		stx	a_vram
		inc	ptr1l	; 5cl
		bne	@l3		; 3cl
		inc	ptr1h
		lda	ptr1h
		cmp	#>(ADDRESS_GFX1_SCREEN+(COLS * 24))	;screen ram $1800 - $1b00
		beq	@l4
@l3:
		inc	ptr2l  ; 5cl
		bne	@l2		; 3cl
		inc	ptr2h
		bra	@l1
@l4:
		ldx	#COLS	; write address is already setup from loop
		lda	#' '
@l5:
		sta	a_vram
		vnops
		dex
		bne	@l5
		rts
inc_cursor_y:
		lda crs_y
		cmp	#ROWS		;last line ?
		bne	@l1
		bra	vdp_scroll_up	; scroll up, dont inc y, exit
@l1:
		inc crs_y
		rts

vdp_chrout:
		cmp	#KEY_CR			;cariage return ?
		bne	@l1
		stz	crs_x
		rts
@l1:
		cmp	#KEY_LF			;line feed
		bne	@l2
		bra	inc_cursor_y
@l2:
		cmp	#KEY_BACKSPACE
		bne	@l3
		lda	crs_x
		beq	@l4
		dec	crs_x
		bra @l5
@l4:	
		lda	crs_y			; cursor y=0, no dec
		beq	@l6
		dec	crs_y
		lda	#(COLS-1)		; set x to end of line above
		sta	crs_x
@l5:
		lda #' '
		bra	vdp_putchar

@l3:
		jsr	vdp_putchar
		lda	crs_x
		cmp	#(COLS-1)
		beq @l7
		inc	crs_x
@l6:	
		rts
@l7:
		stz	crs_x
		bra	inc_cursor_y
    
vdp_putchar:
		pha
		jsr vdp_set_addr
		pla
		sta a_vram
		rts


vdp_set_addr:			; set the vdp vram adress to write one byte afterwards
		lda	crs_y   		; * 32
		asl
		asl
		asl
		asl
		asl
		ora	crs_x
		sta	a_vreg

		lda crs_y   		; * 32
		lsr					; div 8 -> page offset 0-2
		lsr
		lsr
		ora	#WRITE_ADDRESS + >ADDRESS_GFX1_SCREEN
		sta a_vreg
		rts

vdp_init_bytes_gfx1:
		.byte 	0
		.byte	v_reg1_16k|v_reg1_display_on|v_reg1_spr_size
		.byte 	(ADDRESS_GFX1_SCREEN / $400)	; name table - value * $400					--> characters 
		.byte 	(ADDRESS_GFX1_COLOR /  $40)	; color table - value * $40 (gfx1), 7f/ff (gfx2)
		.byte 	(ADDRESS_GFX1_PATTERN / $800) ; pattern table (charset) - value * $800  	--> offset in VRAM 
		.byte	(ADDRESS_GFX1_SPRITE / $80)	; sprite attribute table - value * $80 		--> offset in VRAM
		.byte 	(ADDRESS_GFX1_SPRITE_PATTERN / $800)  ; sprite pattern table - value * $800  		--> offset in VRAM
		.byte	Black
vnopslide:
		nop
		nop
		nop
		nop
		nop
		nop
		nop
		nop
		nop
		nop
		nop
		nop
		nop
		nop
		nop
		nop

		rts
;----------------------------------------------------------------------------------------------
; Output byte as hex string on active output device
;----------------------------------------------------------------------------------------------

hexout:
		pha
		phx

		tax
		lsr
		lsr
		lsr
		lsr				
		jsr hexdigit
		txa 
		jsr hexdigit
		plx
		pla
		rts

hexdigit:
		and     #%00001111      ;mask lsd for hex print
		ora     #'0'            ;add "0"
		cmp     #'9'+1          ;is it a decimal digit?
		bcc     @l	            ;yes! output it
		adc     #6              ;add offset for letter a-f
@l:
		jmp		vdp_chrout

;Put the string following in-line until a NULL out to the console
primm:
PUTSTRI: 
		pla			; Get the low part of "return" address
                                ; (data start address)
        sta     DPL
        pla
        sta     DPH             ; Get the high part of "return" address
                                ; (data start address)
        ; Note: actually we're pointing one short
PSINB:  ldy     #1
        lda     (DPL),y         ; Get the next string character
        inc     DPL             ; update the pointer
        bne     PSICHO          ; if not, we're pointing to next character
        inc     DPH             ; account for page crossing
PSICHO: ora     #0              ; Set flags according to contents of
                                ;    Accumulator
        beq     PSIX1           ; don't print the final NULL
        jsr     vdp_chrout         ; write it out
        bra     PSINB           ; back around
PSIX1:  inc     DPL             ;
        bne     PSIX2           ;
        inc     DPH             ; account for page crossing
PSIX2:  jmp     (DPL)           ; return to byte following final NULL

print_crlf:
		pha
		lda #$0a
		jsr vdp_chrout
		lda #$0d
		jsr vdp_chrout
		pla
		rts

upload:
		jsr print_crlf
		printstring "serial upload "
		; load start address
		jsr uart_rx
		sta startaddr
		
		jsr uart_rx
		sta startaddr+1


		lda startaddr+1
		jsr hexout
		lda startaddr
		jsr hexout

		lda #' '
		jsr vdp_chrout

		jsr upload_ok

		; load number of bytes to be uploaded
		jsr uart_rx
		sta length
			
		jsr uart_rx
		sta length+1

		; calculate end address
		clc
		lda length
		adc startaddr
		sta endaddr

		lda length+1
		adc startaddr+1
		sta endaddr+1

		lda endaddr+1
		jsr hexout

		lda endaddr
		jsr hexout
		
		lda #' '
		jsr vdp_chrout
		

		lda startaddr
		sta addr
		lda startaddr+1
		sta addr+1	

		jsr upload_ok

		ldy #$00
@l1:
		jsr uart_rx
		sta (addr),y

		iny	
		cpy #$00
		bne @l2
		inc addr+1

@l2:		
		; msb of current address equals msb of end address?
		lda addr+1
		cmp endaddr+1
		bne @l1 ; no? read next byte

		; yes? compare y to lsb of endaddr
		cpy endaddr
		bne @l1 ; no? read next byte

		; yes? write OK 

		jsr upload_ok

		lda #'o'
		jsr vdp_chrout			

		lda #'k'
		jsr vdp_chrout
		rts
upload_ok:
		lda #'o'
		jsr uart_tx
		lda #'k'
		jmp uart_tx
		;rts

;----------------------------------------------------------------------------------------------
; Transmit byte VIA SPI
; Byte to transmit in A, received byte in A at exit
; Destructive: A,X,Y
;----------------------------------------------------------------------------------------------

spi_rw_byte:
		sta $e0	; zu transferierendes byte im akku nach tmp0 retten

		ldx #$08
		
		lda via1portb	; Port laden
		and #$fe        ; SPICLK loeschen

		asl		; Nach links rotieren, damit das bit nachher an der richtigen stelle steht
		tay		 ; bunkern

@l:
		rol $e0
		tya		; portinhalt
		ror		; datenbit reinschieben

		sta via1portb	; ab in den port
		inc via1portb	; takt an
		sta via1portb	; takt aus 

		dex
		bne @l		; schon acht mal?
		
		lda via1sr	; Schieberegister auslesen

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
		stz sd_cmd_chksum
		inc sd_cmd_chksum
		rts



dummy_irq:
		rti

num_patterns = $01	
pattern:
	.byte $aa,$55
.SEGMENT "VECTORS"

;----------------------------------------------------------------------------------------------
; Interrupt vectors
;----------------------------------------------------------------------------------------------
; $FFFA/$FFFB NMI Vector
.word dummy_irq
; $FFFC/$FFFD reset vector
;*= $fffc
.word do_reset
; $FFFE/$FFFF IRQ vector
;*= $fffe
.word dummy_irq