;
; Ullrich von Bassewitz, 16.11.2002
;
; int write (int fd, const void* buf, unsigned count);
;

        .export         _write
        .constructor    initstdout

        .import         SETLFS, OPEN, CKOUT, BSOUT, READST, CLRCH
        .import         rwcommon
        .importzp       sp, ptr1, ptr2, ptr3

;        .include        "cbm.inc"
        .include        "errno.inc"
        .include        "fcntl.inc"
 ;       .include        "filedes.inc"


;--------------------------------------------------------------------------
; initstdout: Open the stdout and stderr file descriptors for the screen.

.segment        "INIT"

.proc   initstdout

.endproc

;--------------------------------------------------------------------------
; _write

.code

.proc   _write
.endproc
