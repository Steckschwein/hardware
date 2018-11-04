; MIT License
;
; Copyright (c) 2018 Thomas Woinke, Marko Lauke, www.steckschwein.de
;
; Permission is hereby granted, free of charge, to any person obtaining a copy
; of this software and associated documentation files (the "Software"), to deal
; in the Software without restriction, including without limitation the rights
; to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
; copies of the Software, and to permit persons to whom the Software is
; furnished to do so, subject to the following conditions:
;
; The above copyright notice and this permission notice shall be included in all
; copies or substantial portions of the Software.
;
; THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
; IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
; FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
; AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
; LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
; OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
; SOFTWARE.

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
