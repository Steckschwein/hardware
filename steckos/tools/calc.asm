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

.include "common.inc"
.include "errno.inc"
.include "fcntl.inc"	; @see ca65 fcntl.inc
.include "kernel.inc"
.include "kernel_jumptable.inc"

.include "appstart.inc"

.export char_out=krn_chrout

appstart $1000

	jsr krn_primm
	.byte $d5,$cd,$cd,$cd,$cd,$cd,$b8,$0a
	.byte $b3,"7",$b3,"8",$b3,"9",$b3,$0a
	.byte $b3,"4",$b3,"5",$b3,"6",$b3,$0a
	.byte $b3,"1",$b3,"2",$b3,"3",$b3,$0a
	.byte $b3,"0",$b3,".",$b3,"=",$b3,$0a
	.byte $d4,$cd,$cd,$cd,$cd,$cd,$be,$0a
	.byte $00


exit:
	jmp (retvec)
