.include 	"common.inc"
.include	"kernel.inc"
.include 	"errno.inc"
.include 	"fat32.inc"

.segment "KERNEL"

.import fat_open, fat_read, fat_close
        
.export execv

.ifdef DEBUG ; DEBUG
    .import krn_hexout, krn_primm, krn_chrout, krn_strout, krn_print_crlf
.endif

;		int execv(const char *path, char *const argv[]);
execv:
		jsr fat_open	        ; a/x - pointer to filename
		bne @l_err_exit
		
		lda	fd_area + F32_fd::Attr, x
		bit #DIR_Attr_Mask_File		; check that whether it's a regular file
		bne	@l0
		lda	#EINVAL				; TODO FIXME error code for "Is a directory"
		bra @l_err_exit
		
@l0:	SetVector appstart, read_blkptr
		jsr	fat_read
		pha
		jsr fat_close			; close after read to free fd, regardless of error
		pla
		bne	@l_err_exit
@l_exec_run:
		;TODO FIXME check excecutable - SOS65 header ;)
		jmp	appstart
@l_err_exit:
		debugA "exc:"
		rts
