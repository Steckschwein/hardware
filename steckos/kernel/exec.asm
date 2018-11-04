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


; enable debug for this module
.ifdef DEBUG_EXECV
	debug_enabled=1
.endif
.include "common.inc"
.include "kernel.inc"
.include "errno.inc"
.include "fat32.inc"
.include "fcntl.inc"	; from ca65 api

.segment "KERNEL"

.import fat_open, fat_read, fat_close, fat_read_block, hexout, sd_read_multiblock, inc_lba_address, calc_blocks

.export execv

        ; in:
        ;   A/X - pointer to string with the file path
execv:
		ldy	#O_RDONLY
		jsr fat_open			   	; A/X - pointer to filename
		bne @l_err_exit

		SetVector sd_blktarget, read_blkptr
		phx ; save x register for fat_close
		jsr	fat_read_block
		plx
		jsr fat_close			; close after read to free fd, regardless of error

        lda sd_blktarget
        sta krn_ptr1
		clc
		adc #$fe
		sta read_blkptr

		lda sd_blktarget+1
        sta krn_ptr1+1
        adc #$01
		sta read_blkptr+1

        ldy #$00
@l:
        lda sd_blktarget+2,y
        sta (krn_ptr1),y
        iny
        bne @l

        inc krn_ptr1+1
@l2:
        lda sd_blktarget+$100+2,y
        sta (krn_ptr1),y
        iny
        cpy #$fe
        bne @l2

		dec krn_ptr1+1

        jsr inc_lba_address

        dec blocks
        beq @l_exec_run

		jsr sd_read_multiblock

@l_exec_run:
		; we came here using jsr, but will not rts.
		; get return address from stack to prevent stack corruption
		pla
		pla
        jmp (krn_ptr1)

@l_err_exit:
		debug "exec"
		rts
