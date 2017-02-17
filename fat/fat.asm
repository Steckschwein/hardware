.include "../steckos/asminc/common.inc"
.include "../steckos/kernel/kernel.inc"
.include "../steckos/kernel/kernel_jumptable.inc"
.include "../steckos/kernel/fat32.inc"

	jsr krn_init_sdcard
	lda errno
	beq @ok
	jmp error
@ok:

	jsr krn_mount 
	lda errno
	beq @ok2
	jmp error
@ok2:

	
	lda #<filename
	ldx #>filename
	jsr krn_open
	lda errno
	bne error
	stx tmp

	SetVector $2000, write_blkptr
	SetVector $2000, read_blkptr

	jsr krn_read
	jsr krn_hexout

	ldx tmp
	lda #$00
	sta fd_area + F32_fd::FileSize + 3,x
	sta fd_area + F32_fd::FileSize + 2,x
	sta fd_area + F32_fd::FileSize + 1,x
	lda #$10
	sta fd_area + F32_fd::FileSize + 0,x

	ldy #$00
w:
	lda text,y
	beq done 
	sta $2000,y
	iny
	bra w

done:


	jsr krn_write
	lda #'X'
	jsr krn_chrout
	

loop:	jmp loop
error:
	lda #'E'
	jsr krn_chrout
	lda errno
	jsr krn_hexout
	bra loop

filename: .asciiz "FILE0000.DAT"
text: .asciiz "Es hat geklappt!"
tmp: .res 4 
