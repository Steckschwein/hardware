.include "kernel_jumptable.inc"
.include "zeropage.inc"
.include "common.inc"

.include "appstart.inc"
appstart $1000
		ldx #00
		ldy #00
		jsr krn_textui_crsxy
l_loop0:
		jsr krn_textui_update_crs_ptr
l_loop:
		keyin
		cmp #'1'
		bne @l_1
		dec crs_x
		bra l_loop0
@l_1:
		cmp #'2'
		bne @l_2
		inc crs_x
		bra l_loop0
@l_2:
		cmp #'3'
		bne @l_3
		dec crs_y
		bra l_loop0
@l_3:
		cmp #'4'
		bne @l_esc
		inc crs_y
		bra l_loop0
		
@l_esc:	cmp #KEY_ESCAPE
		beq	l_end
		jsr krn_chrout
		bra l_loop
l_end:
		jmp	(retvec)