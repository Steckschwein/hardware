;
; Ullrich von Bassewitz, 2009-02-22
;
; unsigned char __fastcall__ _sysrename (const char *oldpath, const char *newpath);
;

        .export         __sysrename

        .import         fnparse, fnadd, fnparsename
        .import         popax

        .import         fncmd, fnunit
        .importzp       ptr1


;--------------------------------------------------------------------------
; __sysrename:

.proc   __sysrename

;        jsr     fnparse         ; Parse first filename, pops newpath
 ;       bne     done
done:   rts

.endproc


