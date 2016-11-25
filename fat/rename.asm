.include "../steckos/kernel/kernel.inc"
.include "../steckos/kernel/kernel_jumptable.inc"
.include "../steckos/kernel/fat32.inc"
.include "../steckos/asminc/filedes.inc"



	jsr krn_init_sdcard
	lda errno
	jsr krn_hexout

	jsr krn_mount 
	lda errno
	jsr krn_hexout
	
	lda #<filename
	ldx #>filename
	jsr krn_open
	jsr krn_hexout

	ldy #DIR_Name
@l1:	lda (dirptr),y
	jsr krn_chrout
	iny
	cpy #$0b
	bne @l1

	ldy #DIR_Name
@l2:
	lda newfilename, y
	sta (dirptr),y
	iny
	cpy #$0b
	bne @l2

	SetVector sd_blktarget, sd_write_blkptr

	jsr krn_sd_write_block
	lda errno
	jsr krn_hexout



	
loop:	jmp loop
filename: 
	.asciiz "FILE.DAT"     ;
newfilename: 
	.asciiz "POPANZ  DAT"
