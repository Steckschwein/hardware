.include "common.inc"
.include "vdp.inc"
.include "zeropage.inc"
.include "kernel_jumptable.inc"
.include "appstart.inc"

.import hexout
.importzp ptr2, ptr3

appstart $1000


VRAM_START=$0000

main:
	jsr krn_primm
	.byte $0a, "Video Mem:$",0

	lda #1		; start at vram $4000
	sta vbank

	jmp l_ok
lbank:	
	lda #(WRITE_ADDRESS+>VRAM_START)
	sta adr_h_w
	ldx #>VRAM_START
	stx adr_h_r
	ldy #<VRAM_START
	jsr mem_ca
;	lda	a_vreg	;clear and wait next
;l0: 	bit	a_vreg
;		bpl	l0
ll:	
;		tya
;		and	#$07
;		bne	ln
;l1:	bit	a_vreg
;		bpl	l1
l2:
ln:
	tya
;	jsr hexout
	phy
	ldy adr_h_w	
;	lda adr_h_w
;	jsr hexout

	sei
	
	jsr set_vaddr
	ply
	lda pattern, x
	vnops
	sta a_vram
;	sta test_ptr
	tya
	phy
	vnops
	ldy adr_h_r	
;	vdp_sreg
	jsr set_vaddr
	ply
	vnops
	
	lda a_vram
;	lda test_ptr
	
	jsr rset_vbank
	
	cli
	cmp   pattern, x
	bne   l3
	
	inx
	cpx   #(pattern_e-pattern)		; size of test pattern table
	bne   l2
	ldx   #$00
	iny
	bne   ll
	inc   adr_h_w	; next 256 byte page
	inc   adr_h_r
	jsr   mem_ca
	
	lda	adr_h_r			;TODO vdp bank switch here
	cmp	#$40
	bne   ll
	
	inc vbank
	lda vbank
	cmp #02		;128K ?
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
	phy            ;save vram adress low byte
	ldx #11			; offset output
	ldy crs_y
	jsr krn_textui_crsxy
	lda vbank
	jsr hexout
	lda   #' '
	jsr   krn_chrout
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
	vnops
	ply
	pla
	vdp_sreg
	rts

rset_vbank:
	pha
	phy
	vnops
	lda #0
	ldy #v_reg14
	vdp_sreg	
	ply
	pla
	rts
	
   
pattern:  .byte $f0;,$0f,$96,$69,$a9,$9a,$00,$ff
pattern_e:

adr_h_w:	 .res 2
adr_h_r:	 .res 2
vbank:	 .res 1
test_ptr: .res 1

m_vdp_nopslide