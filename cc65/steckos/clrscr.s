;
; void clrscr (void);
;

        .export         _clrscr
        
		.include        "../../steckos/kernel/ca65/kernel_jumptable.inc"

_clrscr:
        jsr krn_textui_clrscr_ptr
        rts
