;
;
; char cgetc (void);
;
        .export         _cgetc
        .import         cursor
		
		;.include	"defs.inc"

_cgetc: 
        jmp     (invec)