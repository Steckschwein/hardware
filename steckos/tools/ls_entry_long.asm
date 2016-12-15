.segment "CODE"
.include "../kernel/kernel.inc"
.include "../kernel/kernel_jumptable.inc"
.include "../kernel/fat32.inc"


tmp0    = $a0
tmp1    = $a1



.import print_filename
.export dir_show_entry

dir_show_entry:
		pha
		jsr print_filename
	
		lda #' '
		jsr krn_chrout

		ldy #F32DirEntry::Attr
		lda (dirptr),y


		ror
		ror
		ror
		bcc @l1
		lda #'V'
		bra @l4
@l1:
		ror
		bcc @l2
		lda #'S'
		bra @l4
@l2:
		ror
		bcc @l3
		lda #'D'
		bra @l4
@l3:
		lda #'F'	
@l4:
		jsr krn_chrout
		lda #' '
		jsr krn_chrout
		
		ldy #F32DirEntry::FileSize + 2
@l5:		dey
		lda (dirptr),y
		jsr krn_hexout

		cpy #F32DirEntry::FileSize
		bne @l5

		lda #' '
		jsr krn_chrout

		ldy #F32DirEntry::WrtDate 
		lda (dirptr),y
		and #%00011111
		jsr decoutz
	
		; month
		iny
		lda (dirptr),y
		lsr
		tax
		dey
		lda (dirptr),y
		ror
		lsr
		lsr
		lsr
		lsr
		
		jsr decoutz
		
		txa
		clc 
		adc #80   	; add begin of msdos epoch (1980)
		cmp #100	
		bcc @l6		; greater than 100 (post-2000)
		sec 		; yes, substract 100
		sbc #100
@l6:	jsr decoutz ; there we go

	
		lda #' '
		jsr krn_chrout


		ldy #F32DirEntry::WrtTime +1
		lda (dirptr),y
		tax
		lsr
		lsr
		lsr
	
		jsr decoutz

		lda #':'
		jsr krn_chrout


		txa
		and #%00000111
		sta tmp1
		dey
		lda (dirptr),y

		.repeat 5	
		lsr tmp1
		ror 
		.endrepeat

		jsr decoutz


        ; Bits 11–15: Hours, valid value range 0–23 inclusive.
        crlf
	
		pla
		rts	

;----------------------------------------------------------------------------------------------
; decout - output byte in A as decimal ASCII without leading zeros
;----------------------------------------------------------------------------------------------
decout:
		phx
		phy
		ldx #1
		stx tmp1
		inx
		ldy #$40
@l1:
		sty tmp0
		lsr
@l2:	rol
		bcs @l3
		cmp dec_tbl,x
		bcc @l4
@l3:	sbc dec_tbl,x
		sec
@l4:	rol tmp0
		bcc @l2
		tay
		cpx tmp1
		lda tmp0
		bcc @l5
		beq @l6
		stx tmp1
@l5:	eor #$30
		jsr krn_chrout
@l6:	tya
		ldy #$10
		dex
		bpl @l1
		ply
		plx

		rts
decoutz:
		cmp #10
		bcs @l1
		pha
		lda #'0'
		jsr krn_chrout
		pla
@l1:	
		jmp decout
 ; Lookup table for decimal to ASCII
dec_tbl:			.byte 128,160,200
