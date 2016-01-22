;
; void __fastcall__ cputcxy (unsigned char x, unsigned char y, char c);
; void __fastcall__ cputc (char c);
;

        .export         _cputcxy, _cputc, cputdirect, putchar
        .export         newline, plot
        .import         popa, _gotoxy

        .include                "../../lib/defs.inc"
        
_cputcxy:
        pha                     ; Save C
        jsr     popa            ; Get Y
        jsr     _gotoxy         ; Set cursor, drop x
        pla                     ; Restore C

; Plot a character - also used as internal function

_cputc:
        jmp     (outvec)
        
cputdirect:
        jsr     putchar         ; Write the character to the screen

; Advance cursor position

newline:
        lda     #$0d
        jsr     putchar


; Set cursor position, calculate RAM pointers.
plot:   rts                     ;set by vdp chrout


; Write one character to the screen without doing anything else, return X
; position in Y

putchar:
        jmp     (outvec)         ; outvec TODO FIXME use acme label files
        