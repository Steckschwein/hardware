;
; MLA
; Ullrich von Bassewitz, 06.08.1998
;
; unsigned char kbhit (void);
;

        .export         _kbhit
        .import         _cgetc
        
.proc   _kbhit

        ldx     #0              ; High byte of return is always zero
        jsr     _cgetc        
        beq     L9
        lda     #1
L9:     rts

.endproc



