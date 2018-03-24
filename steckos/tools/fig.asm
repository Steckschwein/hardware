.include "common.inc"
.include "vdp.inc"
.include "fcntl.inc"
.include "zeropage.inc"
.include "kernel_jumptable.inc"
.include "appstart.inc"


.importzp ptr2, ptr3
.importzp tmp3, tmp4

.import vdp_gfx2_on
.import vdp_gfx2_blank
.import vdp_display_off
.import vdp_memcpy
.import vdp_mode_sprites_off
.import vdp_bgcolor


	appstart $1000

content = $2000
color=content+$1800

main:
		lda paramptr
		ldx paramptr+1
		ldy #O_RDONLY
		jsr krn_open
		bne @err

		stx tmp1						; save fd
		SetVector content, read_blkptr
		jsr krn_read
		ldx tmp1
		jsr krn_close
		bne @err

		jsr	krn_textui_disable			;disable textui
		SetVector content, addr
		jsr	gfxui_on

		keyin

		jsr	gfxui_off

		jsr	krn_display_off			;restore textui
		jsr	krn_textui_init
		jsr	krn_textui_enable
		cli
		bra l2

@err:
		jsr krn_primm
		.asciiz "load error file "
		lda #<paramptr
		ldx #>paramptr
		jsr krn_strout

l2:		jmp (retvec)

row=$100
blend_isr:
    bit a_vreg
    bpl @0
    save
    lda	#Black
	jsr vdp_bgcolor
	restore
@0:   
		rti

gfxui_on:
   sei
	jsr vdp_display_off			;display off
	jsr vdp_mode_sprites_off	;sprites off

   lda #Black<<4|Black
   jsr vdp_gfx2_blank

   SetVector  content, ptr1
	lda	#<ADDRESS_GFX2_PATTERN
	ldy	#WRITE_ADDRESS + >ADDRESS_GFX2_PATTERN
	ldx	#$18	;6k bitmap - $1800
	jsr	vdp_memcpy					;load the pic data

   SetVector  color, ptr1
	lda	#<ADDRESS_GFX2_COLOR
	ldy	#WRITE_ADDRESS + >ADDRESS_GFX2_COLOR
	ldx	#$18	;6k bitmap - $1800
	jsr	vdp_memcpy					;load the pic data
	
   copypointer  $fffe, irqsafe
	SetVector  blend_isr, $fffe
	
	jsr vdp_gfx2_on			    ;enable gfx2 mode
	
	cli
   rts

gfxui_off:
    sei
    copypointer  irqsafe, $fffe
    cli
    rts

m_vdp_nopslide

irqsafe: .res 2, 0