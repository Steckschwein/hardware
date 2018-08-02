;
;
;	
; int __fastcall__ read(int fd,void *buf,int count)

		.include "fcntl.inc"
      .include "errno.inc"
		.include	"../kernel/kernel_jumptable.inc"
		.include	"../kernel/zeropage.inc"

      .import __rwsetup,__do_oserror,__inviocb,__oserror, popax
		
		.importzp tmp1,tmp2,tmp3,ptr1,ptr2,ptr3,ptr4
		
      .export _read

;--------------------------------------------------------------------------
; _read
.code

.proc   _read
        ; Pop params, check handle
		cmp		#0
		bne		@_r0			; edge case, test if the count argument is zero?
		cpx		#0
		bne		@_r0
        stz     __oserror
		rts		
@_r0:	
		sta     ptr3			
        stx     ptr3+1          ; save given count as result 
		eor     #$FF			; the count argument
        sta     ptr1
        txa
        eor     #$FF
        sta     ptr1+1          ; Remember -count-1

        jsr     popax           ; get pointer to buf
        sta     ptr2
        stx     ptr2+1

        jsr     popax           ; the fd handle
        cpx     #0				; high byte must be 0
        bne     invalidfd
        ;sta     tmp2			; save to tmp2, offset to fd_area
		tax						; fd to x

;		jsr		krn_isOpen
;		bcs     invalidfd

; Read the block
		lda		#<blockbuffer
		sta		read_blkptr
		sta 	ptr4
		lda		#>blockbuffer
		sta		read_blkptr+1
		sta		ptr4+1
		jsr		krn_fread		; TODO FIXME - read single block, x holds the fd
		
		beq		@_r1
        jmp     __directerrno   ; Sets _errno, clears _oserror, returns -1
@_r1:
;		
		ldy		#0
@_r2:
		lda		(ptr4), y
		sta		(ptr2), y
		iny
		bne		@_r3
		inc		ptr2+1
		inc		ptr4+1
		
		lda		ptr4+1		; block buffer end reached?
		cmp		#(>blockbuffer)+2
		bne		@_r3
		lda		#0			; 512 bytes read
		sta 	ptr3
		lda		#2
		sta		ptr3+1
		bra		eof
@_r3:	; count bytes read ?
		inc		ptr1
		bne		@_r2
		inc		ptr1+1
		bne		@_r2
		
; Clear _oserror and return the number of chars read
eof:    lda     #0
        sta     __oserror
        lda     ptr3
        ldx     ptr3+1
        rts

; Error entry: Device not present

devnotpresent:
        lda     #ENODEV
        jmp     __directerrno   ; Sets _errno, clears _oserror, returns -1

; Error entry: The given file descriptor is not valid or not open

invalidfd:
        lda     #EBADF
        jmp     __directerrno   ; Sets _errno, clears _oserror, returns -1

.endproc

blockbuffer:
.res	512,0