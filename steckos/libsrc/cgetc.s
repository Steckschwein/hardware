;
;
; char cgetc (void);
;
        .export         _cgetc
        .import         cursor
		
		.include	"../kernel/kernel_jumptable.inc"

_cgetc: 
        jmp     krn_getkey