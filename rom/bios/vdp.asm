.segment "BIOS"
.export vdp_init, vdp_chrout, vdp_scroll_up

.import primm

.ifdef CHAR6x8
.import charset_6x8
.endif
.ifndef CHAR6x8
.import charset_8x8
.endif

.include "bios.inc"
.include "vdp.inc"

.macro	vnops_l
			jsr vnopslide_long
.endmacro

.macro	vnops
			jsr vnopslide
.endmacro

.macro	SyncBlank
     		lda a_vreg
@lada:
 			bit a_vreg
 			bpl @lada	   ; wait until blank - irq flag set?
.endmacro

.macro vdp_sreg
			vnops
			sta	a_vreg
			vnops
			sty	a_vreg
.endmacro

;----------------------------------------------------------------------------------------------
; init tms99xx with gfx1 mode
;----------------------------------------------------------------------------------------------
vdp_init:
      lda #v_reg1_16k	;enable 16K/64k ram, disable screen
      ldy #v_reg1
      vdp_sreg

.ifdef V9958
			; enable V9958 wait state generator
			lda #1<<2
			ldy #v_reg25
			vdp_sreg

			lda #1<<3 	; assume 64kx4 video ram, so we set bit 3 here TODO FIXME vram detection
			ldy #v_reg8
			vdp_sreg
.endif

			lda	#<ADDRESS_GFX_SPRITE
			ldy	#(WRITE_ADDRESS + >ADDRESS_GFX_SPRITE)
			vdp_sreg
			lda	#$d0					;sprites off, at least y=$d0 will disable the sprite subsystem
			vnops_l
			sta a_vram

			lda	#<ADDRESS_GFX1_SCREEN
			ldy	#(WRITE_ADDRESS + >ADDRESS_GFX1_SCREEN)
			vdp_sreg
			ldy #$00      ;2

			ldx	#$08                    ;8 pages - 8x256 byte, sufficient for 32*24 and 40*24 and 80*24 mode

			lda	#' '					;fill vram screen with blank
@l1:
			vnops_l          ;8
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
			vnops_l         ;8
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
@l3:		vnops_l
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

.export vdp_detect
vdp_detect:
			jsr primm
			.byte "V99",0
      lda #1          ; select sreg #1
      ldy #v_reg15
      vdp_sreg
      vnops_l
      lda a_vreg
      lsr             ; shift right
      and #$1f        ; and mask chip ID#
      clc
      adc #'3'        ; add ascii '3' to ID# value, V9938 ID# = "0", V9958 ID# = "2"
      jsr vdp_chrout
      jsr primm
			.byte "8 VRAM: ",0      
      lda #0          ; select sreg #0
      ldy #v_reg15
      vdp_sreg
      
      ; VRAM detection
      jsr _vdp_detect_vram
      
      ; Ext RAM detection      
_vdp_detect_ext_ram:
      jsr primm
      .asciiz " ExtRAM: "
      lda #v_reg45_MXC
      ldy #v_reg45
      vdp_sreg
      ldx #4  ;max 4 16k banks
      jsr _vdp_detect_ram
      lda #KEY_LF
			jmp vdp_chrout
      
_vdp_detect_vram:
      ldx #8  ;max 8 16k banks
      
_vdp_detect_ram:
      lda #$ff
      sta tmp1  ; the bank, start at $0, first inc below
@l_detect:
      inc tmp1
      dex 
      bmi @l_end    ; we have to break after given amount of banks, otherwise overflow vram address starts from beginning
      lda tmp1
      ldy #v_reg14
      vdp_sreg
      jsr _vdp_bank_available
      beq @l_detect
@l_end:
      lda #0        ;switch back to bank 0 and vram
      ldy #v_reg14
      vdp_sreg
      lda #0
      ldy #v_reg45
      vdp_sreg
      
      ldx #$ff
      lda tmp1
      beq @l_nc
@l_shift:
      inx
      lsr tmp1
      bne @l_shift
      txa
      sta tmp1
      asl tmp1
      adc tmp1
      tay
      ldx #3
:     lda _ram,y
      jsr vdp_chrout
      iny
      dex
      bne :-
      jsr primm
			.byte "KBytes",0
      rts
@l_nc:
      lda #'-'
      jmp vdp_chrout
_ram:
      .byte " 16 32 64128"
      
_vdp_bank_available:
      phx
      jsr _vdp_r_vram
      ldx a_vram

      jsr _vdp_w_vram
      lda tmp1
      sta a_vram
      pha
      vnops_l
      jsr _vdp_r_vram ; ... read back again
      pla
      lda tmp1
      cmp a_vram
      bne @invalid
      jsr _vdp_w_vram
      txa
      sta a_vram
      plx
      lda #0
      rts
@invalid:
      plx
      lda #$ff
      rts
      
bank_end = $3fff
_vdp_w_vram:
      ldy #(WRITE_ADDRESS | >bank_end)
      bra _vdp_vram0
_vdp_r_vram:
      ldy #>bank_end
_vdp_vram0:
      lda #<bank_end
      vdp_sreg
      vnops_l
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
			vnops_l		; wait 2µs, 8Mhz = 16cl => 8 nop
			ldx	a_vram	;
			vnops_l

			lda	ptr2l	; 3cl
			sta	a_vreg
			vnops
			lda	ptr2h	; 3cl
			sta a_vreg
			vnops_l
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
			vnops_l
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
		vnops
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
		ora crs_x
		sta a_vreg

		lda crs_y   		; * 32
		lsr					; div 8 -> page offset 0-2
		lsr
		lsr
		ora #(WRITE_ADDRESS + >ADDRESS_GFX1_SCREEN)
		nop
		nop
		sta a_vreg
		rts

vdp_init_bytes_gfx1:
		.byte 0
		.byte	v_reg1_16k|v_reg1_display_on|v_reg1_spr_size
		.byte (ADDRESS_GFX1_SCREEN / $400)	; name table - value * $400					--> characters
		.byte (ADDRESS_GFX1_COLOR /  $40)	; color table - value * $40 (gfx1), 7f/ff (gfx2)
		.byte (ADDRESS_GFX1_PATTERN / $800) ; pattern table (charset) - value * $800  	--> offset in VRAM
		.byte	(ADDRESS_GFX1_SPRITE / $80)	; sprite attribute table - value * $80 		--> offset in VRAM
		.byte (ADDRESS_GFX1_SPRITE_PATTERN / $800)  ; sprite pattern table - value * $800  		--> offset in VRAM
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
		sta v_l
		rol v_h		   	; save carry if overflow
.else
		; crs_y*32 + crs_y*8  (crs_ptr) => y*40
		sta v_l			; save
.endif

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
		adc v_h			; add carry and page to address high byte
		vnops
		sta a_vreg
		rts

vdp_init_bytes_text:
.ifdef COLS80
	.byte v_reg0_m4	; text mode 2
	.byte v_reg1_16k|v_reg1_display_on|v_reg1_int|v_reg1_m1
	.byte (ADDRESS_GFX1_SCREEN / $1000)| 1<<1 | 1<<0	; name table - value * $1000 (v9958) --> charset
.else
	.byte	0
	.byte v_reg1_16k|v_reg1_display_on|v_reg1_int|v_reg1_m1
	.byte (ADDRESS_GFX1_SCREEN / $1000) 	; name table - value * $400					--> charset
.endif
	.byte 0	; not used
	.byte (ADDRESS_GFX1_PATTERN / $800) ; pattern table (charset) - value * $800  	--> offset in VRAM
	.byte	0	; not used
	.byte 0	; not used
	.byte	Gray<<4|Black
.endif

vnopslide_long: ;64cl
		jsr vnopslide 		; 16cl
		jsr vnopslide 		; 16cl
		jsr vnopslide 		; 16cl
vnopslide:	;8Mhz, 2µs => 16cl = 12cl jsr/rts + 2nop
		nop
		nop
vnopslide_12cl:
		rts
