.include "common.inc"
.include "filedes.inc"
.include "../kernel/kernel.inc"
.include "../kernel/kernel_jumptable.inc"
.include "../kernel/fat32.inc"

	; everything until <space> in the parameter string is the source file name
	ldy #$00
@loop:
	lda (paramptr),y
	beq rename
	cmp #' '
	beq next
	sta filename,y
	iny
	lda #$00
	sta filename,y
	bra @loop

	; after <space> there comes the destination filename
	; copy and normalize it FAT dir entry style

next:
	; first we init the buffer with spaces so we just need to fill in the filename and extension
	ldx #$0b
	lda #' '
@l:
	sta normalizedfilename,x
	dex
	bne @l

	iny
	ldx #$00
@loop:
        lda (paramptr),y
        beq rename
	cmp #'.'
	bne @skip
	
	; found the dot. advance x to pos. 8, point y to the next byte and go again
	iny
	ldx #8
	bra @loop

@skip:
	toupper
	sta normalizedfilename,x
	inx
	iny
	bra @loop

rename:
	SetVector filename, filenameptr
	ldx #FD_INDEX_CURRENT_DIR
	jsr krn_find_first
	lda errno
	beq @go
	printstring "i/o error"

	jmp (retvec)
@go:	bcs @found
	bra error
@found:
	; dirptr still points to the correct dir entry, so just overwrite the name
	ldy #$0b -1
@l:
	lda normalizedfilename,y
	sta (dirptr),y
	dey
	bpl @l

	; set write pointer accordingly and
	SetVector sd_blktarget, sd_write_blkptr

	; just write back the block. lba_address still contains the right address
	jsr krn_sd_write_block
	lda errno

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
