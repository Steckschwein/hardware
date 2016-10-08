;
;
; char cgetc (void);
;
        .export         _cgetc
        .import         cursor
		
		.include	"../kernel/kernel_jumptable.inc"

_cgetc = krn_keyin  ;krn_getkey
