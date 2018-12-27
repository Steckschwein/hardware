;
; Internal include file, do not use directly.
;

;------------------------------------------------------------------------------
; Data structures

.struct DIR
    fd          .word
    off         .word
    name        .byte   8+3+1 +1
.endstruct

;------------------------------------------------------------------------------
; C callable functions

        .global _opendir
        .global _closedir
        .global _readdir
        .global _seekdir
        .global _telldir
        .global _rewinddir
        .global __dirread
        .global __dirread1
