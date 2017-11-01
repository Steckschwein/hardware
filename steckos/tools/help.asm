.include "kernel.inc"
.include "kernel_jumptable.inc"

.segment "CODE"

    jsr krn_primm
    .byte "ll                 - show dir long",$0a
    .byte "ls                 - show dir short",$0a
    .byte "cd <dir>           - change dir",$0a
    .byte "stat <file>        - show file stats",$0a
    .byte "rm <file>          - remove file",$0a
    .byte "mkdir <dir>        - create dir",$0a
    .byte "rmdir <dir>        - remove dir",$0a
    .byte "pwd                - show current dir",$0a
    .byte "date               - show date",$0a
    .byte "rename <from> <to> - rename file",$0a
    .byte "attrib +-a <file>  - set file attribs",$0a
    .byte "up                 - serial upload",$0a
    .byte "rx                 - xmodem upload",$0a
    .byte "fsinfo             - filesystem info",$0a
    .byte "nvram              - manage nvram",$0a
    .byte "setdate            - set rtc date",$0a
    .byte $00

    jmp (retvec)



.segment "INITBSS"
.segment "ZPSAVE"
.segment "STARTUP"
