;
;
; char cgetc (void);
;
        .export         _cgetc
        .import         cursor
_cgetc: 
        jmp     ($0286)