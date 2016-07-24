;
; void __fastcall__ cputcxy (unsigned char x, unsigned char y, char c);
; void __fastcall__ cputc (char c);
;

        .export         _cputcxy, _cputc, cputdirect, putchar
        .export         newline, plot
        .import         popa, _gotoxy

		.include		"../kernel/kernel_jumptable.inc"
        
_cputcxy:
        pha                     ; Save C
        jsr     popa            ; Get Y
        jsr     _gotoxy         ; Set cursor, drop x
        pla                     ; Restore C

cputdirect:
        jmp     krn_chrout      ; Write the character to the screen

; Advance cursor position
newline:
        lda     #$0d
        jmp     krn_chrout


; Set cursor position, calculate RAM pointers.
plot:

; Write one character to the screen without doing anything else, return X
; position in Y
putchar = krn_chrout
        
; Plot a character - also used as internal function
_cputc = krn_chrout
