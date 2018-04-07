.include "common.inc"
.include "vdp.inc"
.include "fcntl.inc"
.include "zeropage.inc"
.include "kernel_jumptable.inc"
.include "appstart.inc"


.importzp ptr2, ptr3
.importzp tmp3, tmp4

.import	hexout
.import vdp_gfx7_on
.import vdp_gfx7_blank
.import vdp_display_off
.import vdp_memcpy
.import vdp_mode_sprites_off
.import vdp_bgcolor

appstart $1000

.code
main:
		lda paramptr
		ldx paramptr+1
		ldy #O_RDONLY
		jsr krn_open
		bne @err
		
		stx fd
		
		SetVector	ppmdata, read_blkptr
		jsr	krn_read_blocks
		bne @err

		jsr parse_header
		;bne	@err
		
		bra @exit
		
		jsr	krn_textui_disable			;disable textui
		jsr	gfxui_on
		keyin
		jsr	gfxui_off

		jsr	krn_display_off			;restore textui
		jsr	krn_textui_init
		jsr	krn_textui_enable
		bra @exit
		
@err:
		jsr krn_primm
		.asciiz " file error, code: "
		jsr	hexout
@exit:	
		ldx fd
		cmp #$ff
		beq @l_exit
		jsr krn_close
@l_exit:
		jmp (retvec)

PPM_P6:	.byte "P6"

parse_header:
		ldy #0
		jsr parse_string
		
		lda #'P'
		cmp buffer
		bne @l_not_ppm
		lda #'6'
		cmp buffer+1
		bne @l_not_ppm
		
		jsr parse_int	;width
		jsr parse_int	;height
		jsr parse_int	;depth
;		cld
		rts
@l_not_ppm:
		jsr krn_primm
		.asciiz " Not valid ppm file!"
		rts
		
parse_int:
		jsr parse_string
		lda buffer, x
		sec
		sbc #'0'
		sed
		rts

parse_string:
		ldx #0
@l0:	lda ppmdata, y
		cmp #20+1		; <= 32 - control characters, treat as whitespace
		bcc @le
		sta buffer, x
		inx
		iny
		bne @l0
@le:	stz buffer, x
		rts

blend_isr:
		bit a_vreg
		bpl @0
		save
		
		lda	#%11100000
		jsr vdp_bgcolor

		lda	#Black
		jsr vdp_bgcolor
	
		restore
@0:
		rti

gfxui_on:
    sei
	jsr vdp_display_off			;display off

	lda #v_reg8_SPD | v_reg8_VR	;
	ldy #v_reg8
	vdp_sreg
	vnops

	jsr vdp_gfx7_on			    ;enable gfx7 mode

	lda #<.HIWORD(ADDRESS_GFX7_SCREEN<<3)
	ldy #v_reg14
	vdp_sreg
	vnops
	lda #<.LOWORD(ADDRESS_GFX7_SCREEN)
	ldy #(WRITE_ADDRESS + >.LOWORD(ADDRESS_GFX7_SCREEN))
	vdp_sreg

    copypointer  $fffe, irqsafe
    SetVector  blend_isr, $fffe

	lda #%00000000	; reset vbank - TODO FIXME, kernel has to make sure that correct video adress is set for all vram operations, use V9958 flag
	ldy #v_reg14
	vdp_sreg	
	
    cli
    rts

gfxui_off:
    sei

    copypointer  irqsafe, $fffe
    cli
    rts

m_vdp_nopslide

irqsafe: .res 2, 0
; TODO FIXME clarify BSS segment voodo 
fd:		.res 1, $ff
buffer:	.res 8, 0

.segment "STARTUP"

.segment "DATA"
ppmdata:	; raw ppm image data blocks
