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
.include "kernel.inc"
.include "kernel_jumptable.inc"
.include "fat32.inc"
.include "appstart.inc"
.include "tools.inc"
.export cnt, files, dirs
.import dir_show_entry, pagecnt, entries_per_page, dir_attrib_mask
.import b2ad2

.export char_out=krn_chrout

appstart $1000
main:

l1:
		crlf
		SetVector pattern, filenameptr

		lda (paramptr)
		beq @l2
		copypointer paramptr, filenameptr

@l2:
		ldx #FD_INDEX_CURRENT_DIR
		jsr krn_find_first
		bcs @l2_1
@io_error:
        .import hexout
        jsr hexout
		printstring " i/o error"
		jmp (retvec)

@l2_1:	bcs @l4
		bra @l5
		; jsr .dir_show_entry
@l3:
		ldx #FD_INDEX_CURRENT_DIR
		jsr krn_find_next
		bne @io_error
        bcc @l5
@l4:
		lda (dirptr)
		cmp #$e5
		beq @l3

		ldy #F32DirEntry::Attr
		lda (dirptr),y

		bit dir_attrib_mask ; Hidden attribute set, skip
		bne @l3

		jsr dir_show_entry

		dec pagecnt
		bne @l
		keyin
		cmp #13 ; enter pages line by line
		beq @lx
		cmp #$03 ; CTRL-C
		beq @l5

		lda entries_per_page
		sta pagecnt
		bra @l
@lx:
		lda #1
		sta pagecnt

@l:

		jsr krn_getkey
		cmp #$03 ; CTRL-C?
		beq @l5
		bra @l3
@l5:


@end:

		jmp (retvec)






pattern:			.byte "*.*",$00
cnt: 	.byte $04
dirs:	.byte $00
files:	.byte $00
