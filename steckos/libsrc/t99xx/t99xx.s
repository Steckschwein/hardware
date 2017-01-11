.include "vdp.inc"
.include "zeropage.inc"

.export	vdp_init_reg
.export	vdp_bgcolor
.export	vdp_nopslide
.export	vdp_fills, vdp_fill
.export	vdp_memcpys

.code
;
;	TODO	
;		improve some functions,  avoid nop for vdp write delay 2µs by opcode reordering
;		investigate the difference between wdc and rockwell if no nop is used
;
m_vdp_nopslide

vdp_irq_off:
		lda #v_reg1_16k|v_reg1_display_on|v_reg1_spr_size	;switch interupt off
		ldy	#v_reg1
		vdp_sreg
		rts

vdp_display_off:
;	jsr	.vdp_wait_blank
		lda		#v_reg1_16k	;enable 16K ram, disable screen
		sta 	a_vreg
		vnops
		lda	  	#v_reg1
		sta   	a_vreg
		rts

vdp_mode_sprites_off:
		lda	#<ADDRESS_GFX_SPRITE
		ldy	#WRITE_ADDRESS + >ADDRESS_GFX_SPRITE
		vdp_sreg
		lda	#$d0					;sprites off, at least y=$d0 will disable the sprite subsystem
		ldx	#32*4
@0:		vnops          	;2
		dex             ;2
		sta   a_vram    ;4
		bne	@0           ;3
		rts
	
; setup video registers upon given table
;	in:
;		ptr1 - pointer set to vdp init table for al 8 vdp registers
vdp_init_reg:
		ldy	#$00
		ldx	#v_reg0
@0:		lda (ptr1),y
		sta a_vreg
		iny
		vnops
		stx a_vreg
		inx
		cpy	#$08
		bne @0
		rts

vdp_wait_blank:
			php
			sei
			SyncBlank
			pla
			and	#$04	;check interupt was set?
			bne	@0
			cli
@0:			rts

;
;   input:	a - color
;
vdp_bgcolor:
	sta   a_vreg
	lda   #v_reg7
	vnops
	sta   a_vreg
	rts

vdp_fill:
;	input:
;		a/y - vram adress
;		x - amount of 256byte blocks (page counter)
;		tmp1 - pattern
			vdp_sreg
			ldy   #0      ;2
			lda tmp1
@0:			vnops          ;2
			iny             ;2
			sta   a_vram    ;
			bne   @0         ;3
			dex
			bne   @0
			rts
	
vdp_fills:
;	input:
;		a/y - vram adress
;		x - amount of bytes
;		tmp1 - fill value
			vdp_sreg
			lda tmp1
@0:			vnops          	;2
			dex             ;2
			sta a_vram    ;4
			bne	@0           ;3
			rts
			
;	input:
;	A(ptr1) to data
;	a - low byte vram adress
;	y - high byte vram adress
;  	x - amount of 256byte blocks (page counter)
vdp_memcpy:
		vdp_sreg
		ldy   #$00      ;2
@l1:	lda   (ptr1),y ;5
		iny             ;2
		vnops
		sta   a_vram    ;1 opcode fetch
		
		bne   @l1         ;3
		inc   ptr1+1
		dex
		bne   @l1
		rts
		
;	input:
;	A(ptr1) to data
;	a - low byte vram adress
;	y - high byte vram adress
;  	x - amount of bytes to copy
vdp_memcpys:
		vdp_sreg
		ldy   #$00
@0:		lda   (ptr1),y ;5
		vnops
		sta   a_vram    ;4
		iny             ;2
		dex             ;2
		bne	@0
		rts
