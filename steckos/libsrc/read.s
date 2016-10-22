;
;
;	
; int __fastcall__ read(int fd,void *buf,int count)

		.include "fcntl.inc"
        .include "errno.inc"
		.include	"../kernel/kernel_jumptable.inc"

        .import __rwsetup,__do_oserror,__inviocb,__oserror, popax
		
		.importzp tmp1,tmp2,tmp3,ptr1,ptr2,ptr3
		
        .export _read

;--------------------------------------------------------------------------
; _read

.code

.proc   _read

        ; Pop params, check handle
        eor     #$FF			; the count argument
        sta     ptr1
        txa
        eor     #$FF
        sta     ptr1+1          ; Remember -count-1
		;TODO FIXME check count>BLOCK_SIZE

        jsr     popax           ; get pointer to buf
        sta     ptr2
        stx     ptr2+1

        jsr     popax           ; the fd handle
        cpx     #$01			; high byte must be 0
        bcs     invalidfd
        sta     tmp2			; save to tmp2, offset to fd_area
		tax
		jsr		krn_isOpen
		bcs     invalidfd

; Read the block
		jsr		krn_read2
		;bne			 TODO error handling

        
		lda     #0		;ok, no error
        sta     __oserror
        lda		#0		;$0200 bytes read
		ldx     #2
        rts
        
@L0:    ;jsr     BASIN
		
; Store the byte just read

        ldy     #0
        lda     tmp1
        sta     (ptr2),y
        inc     ptr2
        bne     @L1
        inc     ptr2+1          ; *buf++ = A;

; Increment the byte count

@L1:    inc     ptr3
        bne     @L2
        inc     ptr3+1
		
; Get the status again and check the EOI bit

@L2:    lda     tmp3
        and     #%01000000      ; Check for EOI
        bne     @L4             ; Jump if end of file reached

; Decrement the count

@L3:    inc     ptr1
        bne     @L0
        inc     ptr1+1
        bne     @L0
        beq     done            ; Branch always

; Set the EOI flag and bail out

@L4:    ldx     tmp2            ; Get the handle
  ;      lda     #LFN_EOF
;        ora     fdtab,x
 ;       sta     fdtab,x
		
done:   ;jsr	krn_close
		;jsr     CLRCH
		
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