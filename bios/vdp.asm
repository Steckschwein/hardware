.segment "BIOS"
.export init_vdp, vdp_chrout
.import charset_8x8
.include "bios.inc"
.include "vdp.inc"
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

; .macro	SyncBlank
;     		lda a_vreg
; @lada:	
; 			bit	a_vreg
; 			bpl @lada	   ; wait until blank - irq flag set?
; .endmacro

.macro vdp_sreg 
			sta	a_vreg
			vnops
			sty	a_vreg	
.endmacro

;----------------------------------------------------------------------------------------------
; init tms9929 into gfx1 mode
;----------------------------------------------------------------------------------------------
init_vdp:
			;display off
			lda		#v_reg1_16k	;enable 16K ram, disable screen
			ldy	  	#v_reg1
			vdp_sreg
			; SyncBlank

			lda	#<ADDRESS_GFX_SPRITE
			ldy	#(WRITE_ADDRESS + >ADDRESS_GFX_SPRITE)
			vdp_sreg
			lda	#$d0					;sprites off, at least y=$d0 will disable the sprite subsystem
			; vnops
			vnops
			sta a_vram

			lda	#<ADDRESS_GFX1_SCREEN
			ldy	#(WRITE_ADDRESS + >ADDRESS_GFX1_SCREEN)
			vdp_sreg
			ldy #$00      ;2
			ldx	#$03                    ;3 pages - 3x256 byte
			lda	#' '					;fill vram screen with blank
@l1: 
			vnops          ;8
			iny             ;2
			sta   a_vram    ;
			bne   @l1        ;3
			dex
			bne   @l1

			stz crs_x
			stz crs_y

			lda #<ADDRESS_GFX1_PATTERN
			ldy #(WRITE_ADDRESS + >ADDRESS_GFX1_PATTERN)
			vdp_sreg
			ldx #$08                    ;load charset
			ldy   #$00     ;2
			SetVector    charset_8x8, addr
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



vdp_scroll_up:
			SetVector	(ADDRESS_GFX1_SCREEN+COLS), ptr1		        	; +COLS - offset second row
			SetVector	(ADDRESS_GFX1_SCREEN+(WRITE_ADDRESS<<8)), ptr2	; offset first row as "write adress"

			lda	a_vreg  ; clear v-blank bit, we dont know where we are...			
@l1:
			bit	a_vreg  ; sync with next v-blank, so that we have the full 4,3µs
			bpl	@l1
@l2:
			lda	ptr1l	; 3cl
			sta	a_vreg
			nop
			lda	ptr1h	; 3cl
			sta	a_vreg
			vnops		; wait 2µs, 8Mhz = 16cl => 8 nop
			ldx	a_vram	;
			vnops
			
			lda	ptr2l	; 3cl
			sta	a_vreg
			nop
			lda	ptr2h	; 3cl
			sta a_vreg
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
			stz	crs_x
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
		ora	#(WRITE_ADDRESS + >ADDRESS_GFX1_SCREEN)
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
		rts