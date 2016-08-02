;
;
; int open(const char *name,int flags,...);
;

;TODO FIXME tmpX stuff
        tmp3 = 19
        
		.include "fcntl.inc"
        .include "errno.inc"
		.include	"../kernel/kernel_jumptable.inc"

        .export _open
        .destructor     closeallfiles, 5

        .import _close
        .import clriocb
        .import fddecusage,newfd
        .import incsp4
        .import ldaxysp,addysp
        .import __oserror
        .importzp tmp4,tmp2
.ifdef  UCASE_FILENAME
        .importzp tmp3
        .import ucase_fn
.endif

.proc   _open

        dey                     ; parm count < 4 shouldn't be needed to be checked
        dey                     ;       (it generates a c compiler warning)
        dey
        dey
        beq     parmok          ; parameter count ok
        jsr     addysp          ; fix stack, throw away unused parameters
		bra		parmok

        lda     #<EMFILE        ; "too many open files"
seterr: jsr     __directerrno
        jsr     incsp4          ; clean up stack
        lda     #$FF
        tax
        rts                     ; return -1

        ; process the mode argument
parmok: ;jsr     krn_open
        ;beq     iocbok          ; we found one
		
iocbok: stx     tmp4
        ldy     #1
        jsr     ldaxysp         ; get mode
        ldx     tmp4
        pha
        and     #O_APPEND
        beq     no_app
        pla
        and     #15
        cmp     #O_RDONLY       ; DOS supports append with write-only only
        beq     invret
        cmp     #O_RDWR
        beq     invret
;        lda     #OPNOT|APPEND
 ;       bne     set


no_app: pla
        and     #15
        cmp     #O_RDONLY
        bne     l1
        ;lda     #OPNIN
set:    ;sta     ICAX1,x
        bne     cont

l1:     cmp     #O_WRONLY
        bne     l2
;        lda     #OPNOT
 ;       bne     set

l2:     ; O_RDWR
  ;      lda     #OPNOT|OPNIN
   ;     bne     set

        ; process the filename argument

cont:   ldy     #3
        jsr     ldaxysp

        ldy     #$80
        sty     tmp2            ; set flag for ucase_fn
;        jsr     ucase_fn
        bcc     ucok1
invret: lda     #<EINVAL        ; file name is too long
        jmp     seterr
ucok1:

        ldy     tmp4

        ;AX - points to filename
        ;Y  - iocb to use, if open needed
;        jsr     newfd           ; maybe we don't need to open and can reuse an iocb
                                ; returns fd num to use in tmp2, all regs unchanged
        bcs     doopen          ; C set: open needed
        lda     #0              ; clears N flag
        beq     finish

doopen: 
        ldx     tmp4
		jsr 	krn_open
		
        ; clean up the stack

finish: php
        txa
        pha
        tya
        pha

        jsr     incsp4          ; clean up stack

        pla
        tay
        pla
        tax
        plp

        bpl     ok
        sty     tmp3            ; remember error code
;		jsr 	krn_close
        lda     tmp3            ; put error code into A
        jmp     __mappederrno

ok:     lda     tmp2            ; get fd
        ldx     #0
        stx     __oserror
        rts

.endproc


; closeallfiles: Close all files opened by the program.

.proc   closeallfiles

;        lda     #MAX_FD_INDEX-1
loop:   ldx     #0
        pha
        jsr     _close
        pla
        clc
        sbc     #0
        bpl     loop
        rts

.endproc
