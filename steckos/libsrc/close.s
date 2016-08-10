;
; Christian Groessler, May-2000
;
; int __fastcall__ close(int fd);
;
		.include	"../kernel/kernel_jumptable.inc"

        .export _close
        .import __do_oserror,popax,__oserror
        .import fdtoiocb_down,__inviocb

.proc   _close
        
        tax     ;   a/x with fd - accu to x, cause it's offset for krn_close
        jsr     krn_close
        bcs     closerr
        
ok:     ldx     #0
        stx     __oserror               ; clear system specific error code
        txa
        rts

inverr: jmp     __inviocb
closerr:jmp     __do_oserror

.endproc

