;
; File generated by cc65 v 2.15
;
	.fopt		compiler,"cc65 v 2.15"
	.setcpu		"65C02"
	.smart		on
	.autoimport	on
	.case		on
	.debuginfo	off
	.importzp	sp, sreg, regsave, regbank
	.importzp	tmp1, tmp2, tmp3, tmp4, ptr1, ptr2, ptr3, ptr4
	.macpack	longbranch
	.import		_open
	.import		_close
	.import		__errno
	.export		_seekdir
	.import		__dirread

; ---------------------------------------------------------------
; void __near__ __fastcall__ seekdir (__near__ struct DIR *, long)
; ---------------------------------------------------------------

.segment	"CODE"

.proc	_seekdir: near

.segment	"CODE"

	jsr     pusheax
	ldy     #$83
	jsr     subysp
	ldy     #$86
	jsr     ldeaxysp
	cmp     #$01
	txa
	sbc     #$10
	lda     sreg
	sbc     #$00
	lda     sreg+1
	sbc     #$00
	bcc     L0005
	lda     #$07
	sta     __errno
	stz     __errno+1
	jmp     L0015
L0005:	ldy     #$88
	jsr     ldaxysp
	jsr     ldaxi
	jsr     _close
	ldy     #$8A
	jsr     pushwysp
	ldy     #$8A
	jsr     ldaxysp
	jsr     incax4
	jsr     pushax
	lda     #$01
	jsr     pusha0
	ldy     #$04
	jsr     _open
	ldy     #$00
	jsr     staxspidx
	ldy     #$88
	jsr     ldaxysp
	jsr     ldaxi
	cpx     #$80
	bcs     L0015
	ldy     #$8A
	jsr     pushwysp
	ldy     #$86
	jsr     ldaxysp
	ldy     #$02
	jsr     staxspidx
	ldy     #$81
	jsr     staxysp
	bra     L0016
L0014:	ldy     #$82
	jsr     ldaxysp
	cmp     #$81
	txa
	sbc     #$00
	bcc     L0018
	lda     #$80
	tay
	sta     (sp),y
	ldx     #$00
	iny
	jsr     subeqysp
	bra     L0021
L0018:	ldy     #$81
	lda     (sp),y
	dey
	sta     (sp),y
	ldx     #$00
	txa
	iny
	jsr     staxysp
L0021:	ldy     #$8A
	jsr     pushwysp
	lda     #$02
	jsr     leaa0sp
	jsr     pushax
	ldy     #$84
	lda     (sp),y
	jsr     __dirread
	tax
	beq     L0015
L0016:	ldy     #$82
	lda     (sp),y
	dey
	ora     (sp),y
	bne     L0014
L0015:	ldy     #$89
	jmp     addysp

.endproc
