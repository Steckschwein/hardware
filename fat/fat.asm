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

	
        lda fd_area + F32_fd::DirEntryLBA+3 , x
        sta lba_addr+3
        lda fd_area + F32_fd::DirEntryLBA+2 , x
        sta lba_addr+2
        lda fd_area + F32_fd::DirEntryLBA+1 , x
        sta lba_addr+1
        lda fd_area + F32_fd::DirEntryLBA+0 , x
        sta lba_addr+0

        lda fd_area + F32_fd::DirEntryPos , x
        jsr krn_hexout
        jsr krn_calc_dirptr_from_entry_nr
        lda dirptr+1
        jsr krn_hexout
        lda dirptr+0
        jsr krn_hexout

        SetVector sd_blktarget, sd_read_blkptr
        jsr krn_sd_read_block

        ldy #$00
@rep:
        lda (dirptr),y
        jsr krn_chrout
        iny
        cpy #12
        bne @rep

foo:	jmp foo

	
	SetVector $2000, sd_write_blkptr
	SetVector $2000, sd_read_blkptr

	jsr krn_read
	jsr krn_hexout


	ldy #$00
w:
	lda text,y
	beq done 
	sta $2000,y
	iny
	bra w

done:
;	ldy #$00
;rep:
	;lda $2000,y
	;jsr krn_hexout
	;lda #' '
	;jsr krn_chrout
	;iny
	;bne rep

	jsr krn_write
	lda errno
	jsr krn_hexout
	


	jsr krn_close
	
	lda #'A'
	jsr krn_chrout

loop:	jmp loop
error:
	lda #'E'
	jsr krn_chrout
	lda errno
	jsr krn_hexout
	bra loop

filename: .asciiz "FILE.DAT"
text: .asciiz "Es hat geklappt!"
tmp: .res 4 
