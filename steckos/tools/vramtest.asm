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
.include "vdp.inc"
.include "zeropage.inc"
.include "kernel_jumptable.inc"
.include "appstart.inc"

.import hexout
.importzp ptr2, ptr3

.export char_out=krn_chrout

appstart $1000

VRAM_START=$4000 ; start from bank 1

main:
	lda	#v_reg8_VR ;64K
	sta a_vreg
    vdp_wait_s
	lda #v_reg8
	sta a_vreg

	jsr krn_primm
	.byte $0a, "Video Mem - Bank:$   Address:$",0

	lda #<(VRAM_START>>14)
	sta vbank

lbank:
	lda #(WRITE_ADDRESS|>(VRAM_START & $3fff))
	sta adr_h_w
	ldx #>(VRAM_START & $3fff)
	stx adr_h_r
	ldy #<(VRAM_START & $3fff)
	jsr mem_ca
l2:
	tya
	phy
	ldy adr_h_w

	sei
	jsr set_vaddr
	ply
	lda pattern, x
	vdp_wait_l 10
	sta a_vram
	tya
	phy
	ldy adr_h_r
	vdp_wait_l 12
    jsr set_vaddr
    ply
    vdp_wait_l 8
	lda a_vram

	jsr rset_vbank		; reset vbank - TODO FIXME, kernel has to make sure that correct video address is set for all vram operations, use V9958 flag
	cli

	cmp pattern, x
	bne l3

	inx
	cpx   #(pattern_e-pattern)		; size of test pattern table
	bne   l2
	ldx   #0
	iny
	bne   l2
	inc   adr_h_w	; next 256 byte page
	inc   adr_h_r
	jsr   mem_ca

	lda	adr_h_r
	cmp	#$40		; 16k reached?
	bne l2

	inc vbank		;vram bank switch
	lda vbank
	cmp #08			;128K ?
	beq l_ok
	jmp lbank

l_ok:
	jsr	krn_primm
	.asciiz " OK"
	jmp	(retvec)

l3:	pha            	;save erroneous pattern
		jsr   mem_ca
		lda   #' '
		jsr   krn_chrout
		pla
		jsr   hexout
		jsr krn_primm
		.asciiz " FAILED"
	jmp (retvec)

mem_ca:	; output value
	phy            	;save vram adress low byte
	ldx #18			; offset output
	ldy crs_y
	jsr krn_textui_crsxy
	lda vbank
	jsr hexout
	ldx #30			; offset output
	ldy crs_y
	jsr krn_textui_crsxy
	lda adr_h_r
	jsr hexout
	pla
	jsr hexout
	rts


set_vaddr:
	pha
	phy
	lda vbank
	ldy #v_reg14
	vdp_sreg
	ply
	pla
	vdp_sreg
	rts

rset_vbank:
	pha
	phy
	lda #0
	ldy #v_reg14
	vdp_sreg
	ply
	pla
	rts


pattern:  .byte $f0,$0f,$96,$69,$a9,$9a,$10,$01
pattern_e:

adr_h_w:	.res 2
adr_h_r:	.res 2
vbank:	 	.res 1

.segment "STARTUP"
