.include 	"common.inc"
.include	"kernel.inc"
.include 	"errno.inc"
.include 	"fat32.inc"

.segment "KERNEL"

.import fat_open, fat_read, fat_close, fat_read_block, hexout, sd_read_multiblock, inc_lba_address, calc_blocks

.export execv

;		int execv(const char *path, char *const argv[]);
execv:
		jsr fat_open	        ; a/x - pointer to filename
		bne @l_err_exit

		lda	fd_area + F32_fd::Attr, x
		bit #DIR_Attr_Mask_File		; check that whether it's a regular file
		bne	@l0
		lda	#EINVAL				; TODO FIXME error code for "Is a directory"
		bra @l_err_exit

@l0:	;SetVector appstart, read_blkptr

        SetVector sd_blktarget, read_blkptr
        jsr	fat_read_block
		jsr fat_close			; close after read to free fd, regardless of error

        lda sd_blktarget+1
        sta krn_ptr1+1
        pha
        jsr hexout
        lda sd_blktarget
        sta krn_ptr1
        pha
        jsr hexout

        ldy #$00
@l:
        lda sd_blktarget+2,y
        sta (krn_ptr1),y
        iny
        bne @l

        inc krn_ptr1+1
@l2:
        lda sd_blktarget+$100+2,y
        sta (krn_ptr1),y
        iny
        cpy #$fe
        bne @l2

        lda sd_blktarget
        clc
        adc #$fe
        sta read_blkptr
        lda sd_blktarget+1
        adc #$01
        sta read_blkptr+1

        ;jsr hexout
        ;lda read_blkptr
        ;jsr hexout

        jsr inc_lba_address
        lda blocks
        beq @l_exec_run

        dec blocks
        beq @l_exec_run

        jsr sd_read_multiblock

        bra @l_exec_run
		bne	@l_err_exit
@l_exec_run:
		;TODO FIXME check excecutable - SOS65 header ;)
		;jmp	appstart

        pla
        sta krn_ptr1
        pla
        sta krn_ptr1+1

        lda krn_ptr1+1
        jsr hexout

        lda krn_ptr1
        jsr hexout

        jmp (krn_ptr1)

@l_err_exit:
		debug "exec"
		rts
