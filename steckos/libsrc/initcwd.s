;
; steckos _cwd
;

        .export         initcwd
        .import         __cwd
        .importzp       sreg, ptr1, ptr2

        .macpack        generic

initcwd:
        lda     #<__cwd
        ldx     #>__cwd
        rts
