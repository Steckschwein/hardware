;
;
; char cgetc (void);
;
        .export         _cgetc
        .import         cursor
		
.include                "../../lib/defs.inc"

_cgetc: 
        jmp     (invec)