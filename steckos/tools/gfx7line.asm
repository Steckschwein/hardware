.include "common.inc"
.include "vdp.inc"
.include "fcntl.inc"
.include "zeropage.inc"
.include "kernel_jumptable.inc"
.include "appstart.inc"


.importzp ptr2, ptr3
.importzp tmp3, tmp4

.import vdp_gfx7_on
.import vdp_gfx7_blank
.import vdp_display_off
.import vdp_memcpy
.import vdp_mode_sprites_off
.import vdp_bgcolor
.import hexout

appstart $1000

pt_x = 25
pt_y = 257
ht_x = 150
ht_y = 150
.code
main:

		jsr	krn_textui_disable			;disable textui
		jsr	gfxui_on

		keyin
		jsr	gfxui_off

		jsr	krn_display_off			;restore textui
		jsr	krn_textui_init
		jsr	krn_textui_enable
		cli

		jmp (retvec)

row=$100
blend_isr:
    bit a_vreg
    bpl @0
	save

    ; lda	#%11100000
	; jsr vdp_bgcolor
	;
    ; lda	#Black
	; jsr vdp_bgcolor
	;
	restore
@0:
	rti

gfxui_on:
    sei
	jsr vdp_display_off			;display off
	jsr vdp_mode_sprites_off	;sprites off


	lda #v_reg8_SPD | v_reg8_VR
	ldy #v_reg8
	vdp_sreg
	vnops

	; lines
	lda #v_reg9_ln
	ldy #v_reg9
	vdp_sreg
	vnops

	jsr vdp_gfx7_on			    ;enable gfx7 mode

	lda #<.HIWORD(ADDRESS_GFX7_SCREEN<<2)
	ldy #v_reg14
	vdp_sreg
	vnops
	lda #<.LOWORD(ADDRESS_GFX7_SCREEN)
	ldy #(WRITE_ADDRESS + >.LOWORD(ADDRESS_GFX7_SCREEN))
	vdp_sreg


	; lda #%00000000
	; jsr vdp_gfx7_blank
	; vnops
	;
	; lda #36
	; ldy #v_reg17
	; vdp_sreg
	; vnops
	;
	; lda #<pt_x
	; sta a_vregi
	; vnops
	;
	; lda #>pt_x
	; sta a_vregi
	; vnops
	;
	; lda #<pt_y
	; sta a_vregi
	; vnops
	;
	; lda #>pt_y
	; sta a_vregi
	; vnops
	;
	; lda #100
	; sta a_vregi
	; vnops
	;
	; lda #0
	; sta a_vregi
	; vnops
	;
	; lda #50
	; sta a_vregi
	; vnops
	;
	; lda #0
	; sta a_vregi
	; vnops
	;
	; lda #%11100000
	; sta a_vregi
	; vnops
	;
	; lda #$0
	; sta a_vregi
	; vnops

	; lda #v_cmd_line
	; sta a_vregi
	; vnops


	vnops

	lda #<pt_x
	ldy #v_reg36
	vdp_sreg
	vnops
	lda #>pt_x
	ldy #v_reg37
	vdp_sreg
	vnops

	lda #<pt_y
	ldy #v_reg38
	vdp_sreg
	vnops
	lda #>pt_y
	ldy #v_reg39
	vdp_sreg
	vnops

	lda #<ht_x
	ldy #v_reg40
	vdp_sreg

	vnops

	lda #>ht_x
	ldy #v_reg41
	vdp_sreg
	vnops

	lda #<ht_y
	ldy #v_reg42
	vdp_sreg
	vnops

	lda #>ht_y
	ldy #v_reg43
	vdp_sreg
	vnops

;	colour
;	GGGRRRBB
	lda #%11100000
	ldy #v_reg44
	vdp_sreg
	vnops



	lda #$0
	ldy #v_reg45
	vdp_sreg
	vnops


	lda #v_cmd_line
	ldy #v_reg46
	vdp_sreg
	vnops

	lda #2
	ldy #v_reg15
	vdp_sreg
@wait:
	vnops
	lda a_vreg
	ror
	bcs @wait

	copypointer  $fffe, irqsafe
	SetVector  blend_isr, $fffe

@end:
	; lda #%00000000	; reset vbank - TODO FIXME, kernel has to make sure that correct video adress is set for all vram operations, use V9958 flag
	; ldy #v_reg14
	; vdp_sreg

    cli
    rts

gfxui_off:
    sei

    copypointer  irqsafe, $fffe
    cli
    rts

m_vdp_nopslide

irqsafe: .res 2, 0

.align 256,0
rgbdata:
; .incbin "531740.raw"


.segment "STARTUP"
