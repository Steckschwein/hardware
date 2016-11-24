.include "../steckos/kernel/kernel.inc"
.include "../steckos/kernel/kernel_jumptable.inc"
.include "../steckos/kernel/fat32.inc"


	jsr krn_init_sdcard
	lda errno
	jsr krn_hexout

;	.repeat 4, i
;	stz lba_addr + i
;	.endrepeat

;	SetVector $2000, sd_read_blkptr
;	jsr krn_sd_read_block

;	lda #$AA
;	sta $2000
;	SetVector $2000, sd_write_blkptr
;	jsr krn_sd_write_block

;	SetVector $2000, sd_read_blkptr
;	jsr krn_sd_read_block

;	ldy #$00
;rep:
;	lda $2000,y
;	jsr krn_hexout
;	lda #' '
;;	jsr krn_chrout
;	iny
;	bne rep


;end:	jmp end

	

	jsr krn_mount 
	lda errno
	jsr krn_hexout
	
	lda #<filename
	ldx #>filename
	jsr krn_open
	jsr krn_hexout
	
	txa
	jsr krn_hexout
	
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
	ldy #$00
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
filename: .asciiz "FILE.DAT"
text: .asciiz "Es hat geklappt!"
