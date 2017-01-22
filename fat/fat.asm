.include "../steckos/asminc/common.inc"
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

;	inc dirptr+1
	
	jsr calc_dir_entry_nr
	jsr krn_hexout
	

	jsr calc_dirptr_from_entry_nr

	lda dirptr +1
	jsr krn_hexout
	lda dirptr +0
	jsr krn_hexout


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

calc_dirptr_from_entry_nr:

	stz dirptr

	lsr
	ror dirptr
	ror 
	ror dirptr
	ror 
	ror dirptr

	clc 
	adc #>sd_blktarget
	sta dirptr+1
	
	rts

calc_dir_entry_nr:
	phx

	lda dirptr
	sta krn_tmp

	lda dirptr+1
	sec
	sbc #>sd_blktarget	

	ldx #$03
	clc
@l:
	rol krn_tmp
	rol 
	dex
	bne @l

	plx
	rts
filename: .asciiz "FILE.DAT"
text: .asciiz "Es hat geklappt!"
tmp: .res 4 
