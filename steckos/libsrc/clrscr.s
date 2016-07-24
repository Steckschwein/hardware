;
; void clrscr (void);
;

        .export         _clrscr
        
		.include		"../kernel/kernel_jumptable.inc"

_clrscr:
        jsr krn_textui_clrscr_ptr
        rts
