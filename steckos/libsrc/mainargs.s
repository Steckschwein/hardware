; mainargs.s

        .constructor    initmainargs, 24
        .import         __argc, __argv

MAXARGS  = 10                   ; Maximum number of arguments allowed
NAME_LEN = 16                   ; Maximum length of command-name

		.include		"../kernel/kernel_jumptable.inc"
		.include		"../kernel/zeropage.inc"

; Get possible command-line arguments. Goes into the special ONCE segment,
; which may be reused after the startup code is run

.segment        "ONCE"

initmainargs:
;        for testing purpose
;        lda     #<INPUT_BUF
;        sta     cmdptr
;        lda     #>INPUT_BUF
;        sta     cmdptr+1

        ldy     #0              ;defense copy to not corrupt shell history
        ldx     #0
L0:     lda     (cmdptr),y
        sta     INPUT_BUF,y
        beq     L1
;        jsr     krn_chrout
        iny
        bne     L0
        dey                     ; null-term if overflow
        lda     #0
        sta     INPUT_BUF,y
L1:
        lda     INPUT_BUF,x
        sta     name,x
        beq     L2
        cmp     #' '
        beq     L3
        inx
        bne     L1              ;overflow is handled above
L2:     inc     __argc
        bra     done

L3:     lda     #0              ; null term string program name
        sta     name,x
        inc     __argc          ; argc always is equal to, at least, 1

; Find the next argument
        ldy     #2              ;args from argv[1..n]
next:   inx
        lda     INPUT_BUF,x
        beq     done            ; End of line reached
        cmp     #' '            ; skip read...
        beq     next

        txa                     ; Get low byte
        clc
        adc     #<INPUT_BUF
        sta     argv,y          ; argv[y]= &arg   ; cmd ptr is page aligned from shell
        iny
        lda     #>INPUT_BUF     ; high byte
        sta     argv,y
        iny
        inc     __argc          ; Found another arg

; Search for the end of the argument
argloop:
        inx
        lda     INPUT_BUF,x
        beq     done
        cmp     #' '            ; read until ' ' or \0
        bne     argloop
        lda     #0              ; 0 terminate the arg
        sta     INPUT_BUF,x

; Check if the maximum number of command line arguments is reached. If not,
; parse the next one.

        lda     __argc          ; Get low byte of argument count
        cmp     #MAXARGS        ; Maximum number of arguments reached?
        bcc     next            ; Parse next one if not

; (The last vector in argv[] already is NULL.)

done:   lda     #<argv
        ldx     #>argv
        sta     __argv
        stx     __argv + 1
        rts

.segment        "INIT"

name:   .res    NAME_LEN + 1

.data
; char* argv[MAXARGS+1]={name};
argv:   .addr   name
        .res    MAXARGS * 2

INPUT_BUF:
    .res    255
;   .byte "test", 0
;    .byte "mainarg 1 2 3 +baz blub -bla", 0
