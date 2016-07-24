;
; os specific error code mapping
; int __fastcall__ _osmaperrno (unsigned char oserror);
;

        .include "errno.inc"
        .export __osmaperrno

.proc   __osmaperrno
        cmp     #$80            ; error or success
        bcs     errcode         ; error, jump

        lda     #0              ; no error, return 0
        tax
        rts

errcode:and     #$7f            ; create index from error number
        tax
        cpx     #MAX_OSERR_VAL  ; valid number?
        bcs     inverr          ; no

        lda     maptable,x
        ldx     #0
        rts

inverr: lda     #<EUNKNOWN
        ldx     #>EUNKNOWN
        rts
.endproc

.rodata

maptable:
;        .byte   EINTR   ;BRKABT = 128           ;($80) BREAK key abort

MAX_OSERR_VAL = (* - maptable)
