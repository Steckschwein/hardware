;
; void __fastcall__ cputcxy (unsigned char x, unsigned char y, char c);
; void __fastcall__ cputc (char c);
;

        .export         _cputcxy, _cputc, cputdirect, putchar
        .export         newline, plot
        .import         popa, _gotoxy

		.include        "../../steckos/kernel/ca65/kernel_jumptable.inc"
        
_cputcxy:
        pha                     ; Save C
        jsr     popa            ; Get Y
        jsr     _gotoxy         ; Set cursor, drop x
        pla                     ; Restore C

cputdirect:
        jsr     putchar         ; Write the character to the screen

; Advance cursor position
newline:
        lda     #$0d

; Set cursor position, calculate RAM pointers.
plot:

; Plot a character - also used as internal function
_cputc:
        lda     #'X'
        jsr     krn_putchar
; Write one character to the screen without doing anything else, return X
; position in Y
putchar:
        jmp     krn_putchar
        