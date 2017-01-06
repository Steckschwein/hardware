.include "../kernel/kernel.inc"
.include "../kernel/kernel_jumptable.inc"
.include "../kernel/fat32.inc"
.include "../asminc/filedes.inc"

	ldy #$00
@loop:
	lda (paramptr),y
	beq out
	cmp #' '
	beq next
	sta filename,y
	iny
	lda #$00
	sta filename,y
	bra @loop

next:
	ldx #$0b
	lda #' '
@l:
	sta normalizedfilename,x
	dex
	bpl @l

	iny
	ldx #$00
@loop:
        lda (paramptr),y
        beq out
	cmp #'.'
	bne @skip

	iny
	ldx #8
	bra @loop

@skip:
	toupper
	sta normalizedfilename,x
	inx
	iny
	bra @loop

out:

	lda #<filename
	ldx #>filename
	jsr krn_open
	bne error

	ldy #$0b
@l:
	lda normalizedfilename,y
	sta (dirptr),y
	dey
	bpl @l

	SetVector sd_blktarget, sd_write_blkptr

	jsr krn_sd_write_block
	lda errno

	jsr krn_close
	cmp #$00
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

	
filename: 
	.res 11
	.byte $00
normalizedfilename:
	.res 11
