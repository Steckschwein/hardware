.include "../steckos/kernel/kernel.inc"
.include "../steckos/kernel/kernel_jumptable.inc"
.include "../steckos/kernel/fat32.inc"

	jsr krn_init_sdcard
	lda errno
	bne error


	jsr krn_mount 
	lda errno
	bne error

	
	lda #<filename
	ldx #>filename
	jsr krn_open
	lda errno
	bne error

	
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
tmp: .byte $00,$00,$00,$00
