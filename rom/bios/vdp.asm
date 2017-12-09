.segment "BIOS"
.export init_vdp, vdp_chrout, vdp_scroll_up

.ifdef CHAR6x8
.import charset_6x8
.endif
.ifndef CHAR6x8
.import charset_8x8
.endif

.include "bios.inc"
.include "vdp.inc"
.macro	vnops
			jsr vnopslide
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

;----------------------------------------------------------------------------------------------
; init tms9929 into gfx1 mode
;----------------------------------------------------------------------------------------------
init_vdp:			
			SyncBlank			;wait blank, display off
			lda		#v_reg1_16k	;enable 16K ram, disable screen
			ldy	  	#v_reg1
			vdp_sreg			

			lda	#<ADDRESS_GFX_SPRITE
			ldy	#(WRITE_ADDRESS + >ADDRESS_GFX_SPRITE)
			vdp_sreg
			lda	#$d0					;sprites off, at least y=$d0 will disable the sprite subsystem
			vnops
			sta a_vram

			lda	#<ADDRESS_GFX1_SCREEN
			ldy	#(WRITE_ADDRESS + >ADDRESS_GFX1_SCREEN)
			vdp_sreg
			ldy #$00      ;2
			
			ldx	#$08                    ;8 pages - 8x256 byte, sufficient for 32*24 and 40*24 and 80*24 mode
			
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
			ldy   #$00
			.ifdef CHAR6x8
			SetVector    charset_6x8, addr
			.endif
			.ifndef CHAR6x8		; 8x8 and 32 cols, also setup colors in color ram
			SetVector    charset_8x8, addr
			.endif
@l2:
			lda   (addr),y ;5
			iny            ;2
			vnops         ;8
			sta   a_vram   ;1 opcode fetch	
			bne   @l2        ;3
			inc   adrh
			dex
			bne   @l2

			; in 8x8 and 32 cols we must setup colors in color vram
			lda	#<ADDRESS_GFX1_COLOR
			ldy	#WRITE_ADDRESS + >ADDRESS_GFX1_COLOR
			vdp_sreg
			lda #Gray<<4|Black          ;enable gfx 1 with gray on black background
			ldx	#$20
@l3:		vnops
			dex         
			sta a_vram  
			bne @l3			

			ldx	#$00					;init vdp regs
			ldy	#v_reg0
@l4:		.ifdef CHAR6x8
			lda vdp_init_bytes_text,x
			.endif
			.ifndef CHAR6x8
			lda vdp_init_bytes_gfx1,x
			.endif			
			vdp_sreg
			iny
			inx
			cpx	#$08
			bne @l4
			rts

vdp_scroll_up:
			SetVector	(ADDRESS_GFX1_SCREEN+COLS), ptr1		        ; +COLS - offset second row
			SetVector	(ADDRESS_GFX1_SCREEN+(WRITE_ADDRESS<<8)), ptr2	; offset first row as "write adress"

			lda	a_vreg  ; clear v-blank bit, we dont know where we are...			
@l1:
			bit	a_vreg  ; sync with next v-blank, so that we have the full 4300µs to copy the vram
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
			cmp	#>(ADDRESS_GFX1_SCREEN+(COLS * 24 + (COLS * 24 .MOD 256)))	;screen ram $1800 - $1b00
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

.ifndef CHAR6x8
vdp_set_addr:				; set the vdp vram adress, write A to vram
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
.endif

.ifdef CHAR6x8
v_l=tmp0
v_h=tmp1
vdp_set_addr:			; set the vdp vram adress, write A to vram
		stz	v_h
		lda crs_y
		asl
		asl
		asl				; crs_y*8
		
.ifdef COLS80
		; crs_y*64 + crs_y*16 (crs_ptr) => y*80 						
		asl				; y*16
		rol v_h		   	; save carry if overflow
.endif
		sta v_l			; save		
		asl		   		; 
		rol v_h		   	; save carry if overflow
		asl				; 
		rol v_h			; save carry if overflow
		adc v_l
		
		bcc @l1
		inc	v_h			; overflow inc page count
		clc				; 
@l1:	adc crs_x		; add x to address
		sta a_vreg
		lda #(WRITE_ADDRESS + >ADDRESS_GFX1_SCREEN)
		adc	v_h			; add carry and page to address high byte
		sta	a_vreg
		rts

vdp_init_bytes_text:
.ifdef COLS80
	.byte 	v_reg0_m4	; text mode 2
	.byte   v_reg1_16k|v_reg1_display_on|v_reg1_int|v_reg1_m1
	.byte 	(ADDRESS_GFX1_SCREEN / $1000)| 1<<1 | 1<<0	; name table - value * $1000 (v9958) --> charset
.else
	.byte	0
	.byte   v_reg1_16k|v_reg1_display_on|v_reg1_int|v_reg1_m1
	.byte 	(ADDRESS_GFX1_SCREEN / $1000) 	; name table - value * $400					--> charset
.endif
	.byte 	0	; not used
	.byte 	(ADDRESS_GFX1_PATTERN / $800) ; pattern table (charset) - value * $800  	--> offset in VRAM 
	.byte	0	; not used
	.byte 	0	; not used
	.byte	Gray<<4|Black
.endif
		
vnopslide:
		nop
		nop
		nop
		nop

.ifdef V9958		
		nop
		nop
		nop
.endif
		rts