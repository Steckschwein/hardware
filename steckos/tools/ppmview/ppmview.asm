; MIT License
;
; Copyright (c) 2018 Thomas Woinke, Marko Lauke, www.steckschein.de
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

;
; use imagemagick $convert <image> -geometry 256 -colort 256 <image.ppm>
;
.include "zeropage.inc"
.include "kernel_jumptable.inc"

.include "appstart.inc"
appstart $1000

.export krn_open, krn_fread, krn_close
.export krn_primm
.export krn_textui_enable
.export krn_textui_disable
.export krn_textui_init
.export krn_display_off
.export krn_getkey
.export char_out=krn_chrout

.export ppmdata
.export ppm_width
.export ppm_height

.code
		.import ppmview_main
		jsr ppmview_main
		jmp (retvec)

ppm_width: .res 1, 0
ppm_height: .res 1, 0 
		
.segment "DATA"
ppmdata: .byte $ff, $aa

.segment "STARTUP"