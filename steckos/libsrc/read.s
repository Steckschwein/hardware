;
; Christian Groessler, Jul-2005
;
; int __fastcall__ read(int fd,void *buf,int count)
;
		.include	"../kernel/kernel_jumptable.inc"

        .import __rwsetup,__do_oserror,__inviocb,__oserror
		
        .export _read

_read:  ;jsr     __rwsetup       ; do common setup for read and write
        ;beq     done            ; if size 0, it's a no-op
        cpx     #$FF            ; invalid iocb?
        beq     _inviocb

		jsr 	krn_read

        beq     done
        jmp     __do_oserror    ; update errno

done:   

okdone: lda     #0
        sta     __oserror       ; clear system dependend error code
        pla                     ; get buf len lo
        rts

_inviocb:
        jmp     __inviocb
