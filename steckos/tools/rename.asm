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

appstart $1000

	; everything until <space> in the parameter string is the source file name
	ldy #$00
@loop:
	lda (paramptr),y
	beq rename
	cmp #' '
	beq next
	sta filename,y
	iny
	lda #$00
	sta filename,y
	bra @loop

	; after <space> there comes the destination filename
	; copy and normalize it FAT dir entry style

next:
	; first we init the buffer with spaces so we just need to fill in the filename and extension
	ldx #$0b
	lda #' '
@l:
	sta normalizedfilename,x
	dex
	bne @l

	iny
	ldx #$00
@loop:
        lda (paramptr),y
        beq rename
	cmp #'.'
	bne @skip

	; found the dot. advance x to pos. 8, point y to the next byte and go again
	iny
	ldx #8
	bra @loop

@skip:
	toupper
	sta normalizedfilename,x
	inx
	iny
	bra @loop

rename:
	SetVector filename, filenameptr
	ldx #FD_INDEX_CURRENT_DIR
	jsr krn_find_first
	bcs @go
	printstring "i/o error"

	jmp (retvec)
@go:	bcs @found
	bra error
@found:
	; dirptr still points to the correct dir entry, so just overwrite the name
	ldy #$0b -1
@l:
	lda normalizedfilename,y
	sta (dirptr),y
	dey
	bpl @l

	; set write pointer accordingly and
	SetVector sd_blktarget, write_blkptr

	; just write back the block. lba_address still contains the right address
	jsr krn_sd_write_block
	bne wrerror
	jmp (retvec)

error:
	jsr krn_primm
	.asciiz "open error"
	jmp (retvec)
wrerror:
	jsr krn_primm
	.asciiz "write error"
	jmp (retvec)


filename:
	.res 11
	.byte $00
normalizedfilename:
	.res 11
