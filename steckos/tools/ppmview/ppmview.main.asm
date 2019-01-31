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
; convert.exe <file>.pdf[page] -resize 256x212^ -gravity center -crop x212+0+0 +repage pic.ppm
;
.setcpu "65c02"
.include "common.inc"
.include "vdp.inc"
.include "joystick.inc"
.include "via.inc"
.include "fat32.inc"
.include "fcntl.inc"
.include "zeropage.inc"

.importzp ptr2

.import hexout
.import vdp_gfx7_on
.import vdp_gfx7_blank
.import vdp_display_off
.import vdp_bgcolor

.import krn_open, krn_fread, krn_close
.import krn_primm
.import krn_textui_enable
.import krn_textui_disable
.import krn_textui_init
.import krn_display_off
.import krn_getkey
.import char_out

.import ppmdata
.import ppm_width
.import ppm_height

.import read_joystick


.export ppmview_main

; for TEST purpose
.export parse_header
.export byte_to_grb

.define MAX_WIDTH 256
.define MAX_HEIGHT 212
.define COLOR_DEPTH 255
.define BLOCK_BUFFER 1 ; as multiple of 3 * 512 byte, so 1 means $600 bytes memory are used

.code
ppmview_main:
        stz fd
		
		lda paramptr
		ldx paramptr+1
;		lda #<filename
;		ldx #>filename
		
		ldy #O_RDONLY
		jsr krn_open
		bne @io_error
		stx fd

		;512byte/block * 3 => 1536byte => div 256 => 6 pixel lines => height / 6 => height / (2*2 + 1*2) => height / 2 * (2+1)
		jsr __calc_blocks
		
		jsr read_blocks
		bne @io_error
		
		jsr parse_header					; .Y - return with offset to first data byte
		bne @invalid_ppm
		sty data_offset
		
		jsr gfxui_on

		jsr load_image
		bne @gfx_io_error

		jsr wait_key
		
		jsr gfxui_off
		
		bra @close_exit

@invalid_ppm:
		jsr krn_primm
		.byte $0a,"Not a valid ppm file! Must be type P6 with max. ", .string(MAX_WIDTH), "x", .string(MAX_HEIGHT), "px and 8bpp colors.",0
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
		beq @l_exit
		jsr krn_close
@l_exit:
		jmp (retvec)

filename:
;	.asciiz "pic22.ppm"
;	.asciiz "felix.ppm"
				
read_blocks:
		SetVector ppmdata, read_blkptr
		ldx fd
		ldy #(3*BLOCK_BUFFER) ; multiples of 3 blocks at once, cause of the ppm header and alignment
		jmp krn_fread		

load_image:
		stz cols
		stz rows
		
		jsr set_screen_addr	; initial vram address
		
		ldy data_offset ; .Y - data offset
@loop:
		SetVector ppmdata, read_blkptr ; reset ptr to begin of buffer	
		jsr blocks_to_vram
		
		jsr read_blocks
		bne @l_exit
		cpy #0	; no blocks where read
		beq @l_exit
		jsr adjust_blocks
		bra @loop
@l_exit:
		rts
		
adjust_blocks:
@l:	jsr dec_blocks
		beq @l_exit ; zero blocks reached
		dey
		bne @l
@l_exit:
		rts
		
blocks_to_vram:
		jsr byte_to_grb
		sta a_vram
;		jsr hexout
		inc cols
		lda cols
		cmp ppm_width
		bne @l1
		stz cols
		inc rows
		lda rows
;		jsr hexout
		cmp ppm_height
		beq @l_exit
		jsr set_screen_addr
@l1:
		lda read_blkptr+1
		cmp #>(ppmdata+(BLOCK_BUFFER*3*$200))	;end of 3 blocks reached?
		bne blocks_to_vram
@l_exit:
		rts
			
next_byte:
		lda (read_blkptr),y
		iny
		beq @l_inc
		rts		
@l_inc:
		inc read_blkptr+1
		rts
		
byte_to_grb:
		jsr next_byte	;R
		and #$e0
		lsr
		lsr
		lsr
		sta tmp
		jsr next_byte	;G
		and #$e0
		ora tmp
		sta tmp
		jsr next_byte	;G
		rol
		rol
		rol
		and #$03		;blue - bit 1,0
		ora tmp
		rts
		
wait_key:
		keyin
		cmp #'q'
		beq :+
;        cmp #'s'
 ;       bne wait_key
  ;      lda scroll_on
   ;     eor #$ff
    ;    sta scroll_on
        bra wait_key
:		rts
		
set_screen_addr:
		sei	;critical section, avoid vdp irq here
        vdp_wait_s
		lda cols
		sta a_vreg                 ; A7-A0 vram address low byte
		lda rows
		and #$3f                   ; A13-A8 vram address highbyte
		ora #WRITE_ADDRESS
		vdp_wait_s 4
		sta a_vreg
		lda rows                   ; A16-A14 bank select via reg#14
		rol
		rol
		rol
		and #$03
		ora #<.HIWORD(ADDRESS_GFX7_SCREEN<<2)
		vdp_wait_s
		sta a_vreg
		vdp_wait_s 2
		lda #v_reg14
		sta a_vreg
		cli
		rts		
		
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
		lda #'P'
		cmp ppmdata
		bne @l_invalid_ppm
		lda #'6'
		cmp ppmdata+1
		bne @l_invalid_ppm

		ldy #0
		jsr parse_string		;skip "P6"
		
		jsr parse_until_size	;skip until <width> <height>
		jsr parse_int	;width
		cmp #<MAX_WIDTH
		bcc @l_invalid_ppm ;
		sta ppm_width
		jsr parse_int	;height
		cmp #MAX_HEIGHT+1
		bcs @l_invalid_ppm
		sta ppm_height
		sty tmp2;safe y offset, to check how many chars are consumed during parse
		jsr parse_int	;depth
		cmp #COLOR_DEPTH
		bne @l_exit
		tya
		sec
		sbc tmp2
		cmp #4+1 ; check that 3 digits + 1 delimiter was parsed, so number is <=3 digits
		bcs @l_invalid_ppm
		lda #0
		rts
@l_invalid_ppm:
		lda #$ff
@l_exit:
		rts

parse_until_size:
		lda ppmdata, y
		cmp #'#'				; skip comments
		bne @l		
		jsr parse_string
		bra parse_until_size
@l:	
		rts
		
parse_int:
		stz tmp
@l_toi:
		lda ppmdata, y
		cmp #'0'
		bcc @l_end
		cmp #'9'+1
		bcs @l_end
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
		iny
		bne @l_toi
@l_end:
		iny
		lda tmp
		rts

parse_string:
		ldx #0
@l0:	lda ppmdata, y
		cmp #$20		; < $20 - control characters are treat as whitespace
		bcc @le
		iny
		bne @l0
@le:	iny
		rts
			
blend_isr:
		vdp_wait_s
		bit a_vreg
		bpl @0
		save
		
		lda #%01001010
		jsr vdp_bgcolor
		
		; irq Payload here
        
        bit scroll_on
        bpl :+
        jsr scroll
:
		lda #Black
		jsr vdp_bgcolor
		
		restore		
@0:
		rti

scroll:
        lda scroll_x
		and #7
        ldy #v_reg27
		vdp_sreg
        lda scroll_x
        bit #7
        bne :+
        sec
        sbc #8
        tay
        sbc #8
        sta scroll_x
        dey
        tya
        
:       lsr
        lsr
        lsr
        
        ldy #v_reg26
        vdp_sreg

        
        lda #JOY_PORT2
        jsr read_joystick
        bit #JOY_LEFT
        bne :+
        dec scroll_x
        bra @l_exit
:       bit #JOY_RIGHT
        bne @l_exit
        inc scroll_x
        
@l_exit:       
        rts
        
gfxui_on:	
		jsr krn_textui_disable			;disable textui

		sei
		jsr vdp_display_off			;display off
		jsr vdp_gfx7_on			   ;enable gfx7 mode

		vdp_sreg v_reg9_ln, v_reg9
		
		lda #%00000000
		jsr vdp_gfx7_blank

        vdp_sreg v_reg25_wait | v_reg25_msk, v_reg25

        lda #$ff
		sta scroll_on
        stz scroll_x
        jsr scroll
        
		copypointer  $fffe, irqsafe
		SetVector  blend_isr, $fffe

		cli
		rts

gfxui_off:
		sei
		
		vdp_sreg 0, v_reg9
		
        vdp_sreg v_reg25_wait, v_reg25
        
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
		
data_offset: .res 1, 0
cols: .res 1, 0
rows: .res 1, 0
fd: .res 1, 0
tmp: .res 1, 0
tmp2: .res 1, 0
scroll_on: .res 1, 0
scroll_x: .res 1, 0
irqsafe: .res 2, 0