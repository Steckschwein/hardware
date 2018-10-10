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
.setcpu "65c02"
.include "common.inc"
.include "vdp.inc"
.include "fat32.inc"
.include "fcntl.inc"
.include "zeropage.inc"

.importzp ptr2, ptr3
;.importzp tmp, tmp4

.import hexout
.import vdp_gfx7_on
.import vdp_gfx7_blank
.import vdp_display_off
.import vdp_memcpy
.import vdp_mode_sprites_off
.import vdp_bgcolor

.import krn_open, krn_fread, krn_close
.import krn_primm
.import krn_textui_enable
.import krn_textui_disable
.import krn_textui_init
.import krn_display_off
.import krn_getkey


.import ppmdata
.import ppm_width
.import ppm_height

.export ppmview_main

; for TEST purpose
.export parse_header

.define MAX_WIDTH 256
.define MAX_HEIGHT 192

.code
ppmview_main:
		lda paramptr
		ldx paramptr+1
;		SetVector filename, paramptr
;		lda paramptr
;		ldx paramptr+1
		
		stz fd
		
		ldy #O_RDONLY
		jsr krn_open
		bne @io_error
		stx fd

		;512byte/block * 3 => 1536byte => div 256 => 6 pixel lines => height / 6 => height / (2*2 + 1*2) => height / 2 * (2+1)
		jsr __calc_blocks

		jsr read_blocks
		bne @io_error
		
		jsr adjust_blocks
;		
		jsr parse_header					; return with offset to first data byte
		bne @invalid_ppm

		jsr	gfxui_on

		jsr load_image
		bne @gfx_io_error
		
;		keyin
		
		jsr	gfxui_off
		bra @close_exit

@invalid_ppm:
		jsr krn_primm
		.byte $0a,"Not a valid ppm file! Must be type P6 with size 256x192px.",0
		bra @close_exit

@gfx_io_error:
		pha
		jsr gfxui_off
		pla
@io_error:
		pha
		jsr krn_primm
		.byte $0a,"i/o error, code: ",0
		pla
		jsr hexout
@close_exit:
		ldx fd
		beq l_exit
		jsr krn_close
l_exit:
		jmp (retvec)

read_blocks:
		lda blocks+2
		jsr hexout
		lda blocks+1
		jsr hexout
		lda blocks+0
		jsr hexout

		SetVector ppmdata, read_blkptr
		ldx fd
		ldy #3 ; 3 blocks at once, cause of the ppm header and alignment
		jmp krn_fread
		
adjust_blocks:
;		phy
;		tya
;		jsr hexout
;		ply
		cpy #0	; no blocks where read
		beq @l_exit
@l:	jsr dec_blocks
		beq @l_exit ; zero blocks reached
		dey
		bne @l
		lda #$ff	; more to go
@l_exit:
		rts

load_image:
		jsr read_blocks
		bne @l_exit
		jsr adjust_blocks
		bne load_image
@l_exit:
		rts

	lda #<.HIWORD(ADDRESS_GFX7_SCREEN<<3)
	ldy #v_reg14
	vdp_sreg
	vnops
	lda #<.LOWORD(ADDRESS_GFX7_SCREEN)
	ldy #(WRITE_ADDRESS + >.LOWORD(ADDRESS_GFX7_SCREEN))
	vdp_sreg

	lda #%00000000	; reset vbank - TODO FIXME, kernel has to make sure that correct video adress is set for all vram operations, use V9958 flag
	ldy #v_reg14
	vdp_sreg	 
;	vdp_reg 14,0

dec_blocks:
		lda blocks+0
		bne @l0
		lda blocks+1
		bne @l1
		dec blocks+2
@l1:	dec blocks+1
@l0:	dec blocks+0
		lda blocks+2	
		ora blocks+1
		ora blocks+0	;Z=1 if zero
		rts
		
parse_header:
		ldy #0
		jsr parse_string

		lda #'P'
		cmp buffer
		bne @l_not_ppm
		lda #'6'
		cmp buffer+1
		bne @l_not_ppm
		
		jsr parse_int	;width
		cmp #<MAX_WIDTH
		bne @l_not_ppm
		sta ppm_width
		jsr parse_int	;height
		cmp #MAX_HEIGHT
		bcs @l_not_ppm
		sta ppm_height
		jsr parse_int	;depth
		lda #0
		rts
@l_not_ppm:
		lda #$ff
		rts

parse_int:
		jsr parse_string
		stz tmp
		ldx #0
:
		lda buffer, x
		beq :+		
		pha		;n*10 => n*2 + n*8
		lda tmp
		asl
		sta tmp
		asl
		asl
		adc tmp
		sta tmp
		pla
		sec
		sbc #'0'
		clc
		adc tmp
		sta tmp
		inx
		bne :-	
:		lda tmp
		rts

parse_string:
		ldx #0
@l0:	lda ppmdata, y
		cmp #$20+1		; <= $20 - control characters are treat as whitespace
		bcc @le
		sta buffer, x
		inx
		iny
		bne @l0
@le:	iny
		stz buffer, x
		rts

blend_isr:
		save
		
		lda #Dark_Yellow
		jsr vdp_bgcolor
		
		bit a_vreg
		bpl @0
		
		; irq Payload here
		
@0:
		lda #Black
		jsr vdp_bgcolor
		
		restore
		rti

gfxui_on:
	
	jsr	krn_textui_disable			;disable textui

	sei
	jsr vdp_display_off			;display off

	jsr vdp_gfx7_on			   ;enable gfx7 mode

	copypointer  $fffe, irqsafe
	SetVector  blend_isr, $fffe
	
	cli
	rts

gfxui_off:
		sei
		copypointer  irqsafe, $fffe
		cli
		
		jsr	krn_display_off			;restore textui
		jsr	krn_textui_init
		jsr	krn_textui_enable
	 
		rts

	; TODO FIXME => lib
__calc_blocks: ;blocks = filesize / BLOCKSIZE -> filesize >> 9 (div 512) +1 if filesize LSB is not 0
		lda fd_area + F32_fd::FileSize + 3,x
		lsr
		sta blocks + 2
		lda fd_area + F32_fd::FileSize + 2,x
		ror
		sta blocks + 1
		lda fd_area + F32_fd::FileSize + 1,x
		ror
		sta blocks + 0
		bcs @l1
		lda fd_area + F32_fd::FileSize + 0,x
		beq @l2
@l1:	inc blocks
		bne @l2
		inc blocks+1
		bne @l2
		inc blocks+2
@l2:	lda blocks+2
		ora blocks+1
		ora blocks+0
		rts
		
m_vdp_nopslide

irqsafe: .res 2, 0
; TODO FIXME clarify BSS segment voodo
fd: .res 1, 0
tmp: .res 0
buffer: .res 8, 0
