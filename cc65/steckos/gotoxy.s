;
; void gotoxy (unsigned char x, unsigned char y);
;
        .export         _gotoxy
        .import         popa
        
crs_x	= $e6
crs_y	= $e7


_gotoxy:
        sta     crs_y
        jsr     popa            ; Get X 
        sta     crs_x   ; Set X
        rts