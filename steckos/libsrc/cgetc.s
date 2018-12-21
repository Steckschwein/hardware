;
;
; char cgetc (void);
;
        .export         _cgetc
        .import         cursor
		
		.include	"../kernel/kernel_jumptable.inc"

_cgetc: 
	jsr krn_getkey
	bcc _cgetc