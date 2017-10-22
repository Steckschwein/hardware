.include "common.inc"
.include "../kernel/kernel.inc"
.include "../kernel/kernel_jumptable.inc"
.include "../kernel/fat32.inc"
.include "appstart.inc"

appstart $1000

		ldy #$00
@loop:
		lda (paramptr),y
		cmp #'+'
		beq param
		cmp #'-'
		beq param

		iny
		bne @loop
end:
		jmp (retvec)

param:
		sta op
		iny

		lda (paramptr),y
		and #$DF
		ldx #$00
		cmp #'A'
		bne @l1
		ldx #DIR_Attr_Mask_Archive
@l1:	cmp #'H'
		bne @l2
		ldx #DIR_Attr_Mask_Hidden
@l2:	cmp #'R'
		bne @l3
		ldx #DIR_Attr_Mask_ReadOnly
@l3:	cmp #'S'
		bne @l4
		ldx #DIR_Attr_Mask_System
@l4:

		stx atr
		lda atr
		bne @l5
		jsr krn_primm
		.byte "invalid attribute",$00
		jmp (retvec)
@l5:

		iny

		; everything until <space> in the parameter string is the source file name
		iny
		ldx #$00
@loop:
		lda (paramptr),y
		beq attrib
		sta filename,x
		iny
		inx
		stz filename,x
		bra @loop

attrib:


		SetVector filename, filenameptr
		ldx #FD_INDEX_CURRENT_DIR
		jsr krn_find_first
		bcs @found
		printstring "i/o error"
		jmp (retvec)

@found:

		lda atr
		ldx op
		cpx #'+'
		bne @l1
		jsr set_attrib
		bra @save
@l1:	jsr unset_attrib
@save:

		; set write pointer accordingly and
		SetVector sd_blktarget, write_blkptr

		; just write back the block. lba_address still contains the right address
		jsr krn_sd_write_block
		bne wrerror
		jmp (retvec)

error:
		jsr krn_primm
		.asciiz "open error"
		jmp (retvec)
wrerror:
		jsr krn_primm
		.asciiz "write error"
		jmp (retvec)

; set attribute bit
; in:
;   A - attribute bit to set
set_attrib:
		ldy #F32DirEntry::Attr
		ora (dirptr),y
		sta (dirptr),y
		rts

; clear attribute bit
; in:
;   A - attribute bit to unset
unset_attrib:
		eor #$ff 				; make complement mask
		ldy #F32DirEntry::Attr
		and (dirptr),y
		sta (dirptr),y
		rts

filename:
		.res 11
		.byte $00
op:		.byte $00
atr:	.byte $00
