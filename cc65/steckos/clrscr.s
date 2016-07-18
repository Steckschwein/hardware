;
; void clrscr (void);
;

        .export         _clrscr
        
		.include        "../../steckos/kernel/ca65/kernel_jumptable.inc"

_clrscr = krn_textui_clrscr_ptr