;
; void gotoxy (unsigned char x, unsigned char y);
;
        .export         _gotoxy
        .import         popa
        
		.include        "../../steckos/kernel/ca65/zeropage.inc"
		.include        "../../steckos/kernel/ca65/kernel_jumptable.inc"
		
_gotoxy:
        sta     crs_y
        jsr     popa    ; Get X 
        sta     crs_x   ; Set X
        jmp     krn_textui_update_crs_ptr