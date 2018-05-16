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

.segment "CODE"
.include "../kernel/kernel.inc"
.include "../kernel/kernel_jumptable.inc"
.include "../kernel/fat32.inc"
.include "../asminc/common.inc"
.include "tools.inc"


.import b2ad, dpb2ad, print_fat_date, print_fat_time
.import print_filename, files, dirs
.export dir_show_entry, pagecnt, entries_per_page, dir_attrib_mask

dir_show_entry:
		pha
		jsr print_filename

		lda #' '
		jsr krn_chrout

		ldy #F32DirEntry::Attr
		lda (dirptr),y


		bit #DIR_Attr_Mask_Dir
		beq @l
		jsr krn_primm
		.byte "<DIR> ",$00
		inc dirs
		bra @date				; no point displaying directory size as its always zeros
								; just print some spaces and skip to date display
@l:
		ldy #F32DirEntry::FileSize +1
		lda (dirptr),y
		tax
		dey
		;ldy #F32DirEntry::FileSize
		lda (dirptr),y

		jsr dpb2ad

		lda #' '
		jsr krn_chrout
		inc files
@date:
		ldy #F32DirEntry::WrtDate
		jsr print_fat_date


		lda #' '
		jsr krn_chrout


		ldy #F32DirEntry::WrtTime +1
		jsr print_fat_time
        crlf


		pla
		rts



entries = 23
dir_attrib_mask:  .byte $0a

entries_per_page: .byte entries
pagecnt: .byte entries
