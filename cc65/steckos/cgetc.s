;
;
; char cgetc (void);
;
        .export         _cgetc
        .import         cursor
		
		.include        "../../steckos/kernel/ca65/kernel_jumptable.inc"

_cgetc: 
        jmp     krn_getkey