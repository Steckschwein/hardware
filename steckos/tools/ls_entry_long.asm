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

.segment "CODE"
.include "kernel.inc"
.include "kernel_jumptable.inc"
.include "fat32.inc"
.include "common.inc"
.include "tools.inc"


.import print_fat_date, print_fat_time, print_filesize, print_filename
.import files, dirs
.import char_out
.export dir_show_entry, pagecnt, entries_per_page, dir_attrib_mask


dir_show_entry:
		pha
		jsr print_filename



		ldy #F32DirEntry::Attr
		lda (dirptr),y

		bit #DIR_Attr_Mask_Dir
		beq @l
		jsr krn_primm
		.byte "  <DIR> ",$00
		inc dirs
		bra @date				; no point displaying directory size as its always zeros
								; just print some spaces and skip to date display
@l:
		jsr print_filesize

		lda #' '
		jsr krn_chrout
		inc files
@date:
		jsr print_fat_date


		lda #' '
		jsr krn_chrout


		jsr print_fat_time
        crlf

		pla
		rts


entries = 23
dir_attrib_mask:  .byte $0a

entries_per_page: .byte entries
pagecnt: .byte entries
