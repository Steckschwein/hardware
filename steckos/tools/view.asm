.include "../kernel/kernel.inc"
.include "../kernel/kernel_jumptable.inc"
.include "../asminc/vdp.inc"
.include "../kernel/fat32.inc"

content = $2000	

collor_offs=$1800    
color=content+collor_offs

main:
	
	copypointer paramptr, filenameptr

	
	jsr krn_open
 	phx
 
	lda errno
	bne err

	SetVector content, sd_read_blkptr
	jsr krn_read	

	plx
	jsr krn_close
	lda errno
	bne err	

	jsr	textui_disable			;disable textui
	SetVector content, addr
    	jsr	gfxui_on
    	jsr	gfxui_blend_on
@l:	jsr keyin
	beq @l
	jsr	gfxui_blend_off
	jsr	gfxui_off
    
	jsr	display_off			;restore textui
	jsr	textui_init
	jsr	textui_enable
	cli
	bra l2

err:
	jsr krn_primm
	.asciiz "load error"

l2:	jmp (retvec)

row=$100
gfxui_blend_off:
	lda #Transparent<<4|Transparent
	bra l3
gfxui_blend_on:
	lda #$ff
l3:
	sta tmp2
	SetVector  ((WRITE_ADDRESS<<8)+ADDRESS_GFX2_COLOR+0),          ptr1
	SetVector  ((WRITE_ADDRESS<<8)+ADDRESS_GFX2_COLOR+row+$f8),   ptr2; +1 row and $f8 end of line

	stz tmp0
	lda #8
	sta tmp1
	lda #$f8
	sta tmp3
	stz tmp4
	stz tmp5
    
@l:
	bit tmp5    ;sync with isr
	bpl @l
	stz tmp5
    
	ldx	#12
@l2:	lda ptr1l
	ldy ptr1h
	vdp_sreg
 	ldy tmp0
@c:	lda color,y
	and tmp2
	sta a_vram
	iny
	cpy tmp1
	bne @c
	inc @c+2
	inc @c+2
	inc ptr1h
	inc ptr1h
	dex
	bne @l2

	sty tmp0    ;new offset
	sty ptr1l
	tya
	clc
	adc #08
	sta tmp1
    
	lda #((WRITE_ADDRESS)+>ADDRESS_GFX2_COLOR)
	sta ptr1h
	lda #>color
	sta @c+2
    
	ldx	#12
@l3:
	lda ptr2l
	ldy ptr2h
	vdp_sreg
	ldy tmp3
@c2:	lda color+row,y
	and tmp2
	sta a_vram
	iny
	cpy tmp4
	bne @c2
	inc @c2+2
	inc @c2+2
	inc ptr2h
	inc ptr2h
	dex
	bne  @l3
    
	lda tmp3
	sta tmp4
	sec
	sbc #08
	sta tmp3
	sta ptr2l

	lda #((WRITE_ADDRESS)+>ADDRESS_GFX2_COLOR+row+$f8)
	sta ptr2h
	lda #>color+row
	sta @c2+2
	lda tmp0
	beq @l4
	jmp @l
@l4:	rts


