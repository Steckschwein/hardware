;
; void clrscr (void);
;

        .export         _clrscr
        
		.include		"../../steckos/kernel/kernel.inc"

_clrscr = krn_textui_clrscr_ptr