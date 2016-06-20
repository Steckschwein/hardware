.setcpu "65C02"
.segment "CODE"

; 	system attribute has to be set on file system
memctl = $0230
dest = $f000


; .pages = (.payload_end - .payload) / 256 + 1

	stz memctl

	; copy kernel code to $e000

loop:
@a:	lda payload
@b:	sta dest

	inc @a+1
	inc @b+1
	bne loop

	lda @a+2
	cmp #>payload_end
	bne @skip
	
	lda @a+1
	cmp #<payload_end
	bne @skip
	bra end
@skip:
	inc @a+2
	inc @b+2
	bne loop

end:

	;display off
; 	lda		#v_reg1_16k	;enable 16K ram, disable screen
; 	sta 	a_vreg
; 	+vnops
; 	lda	  	#v_reg1
; 	sta   	a_vreg
	

; 	; copy 6x8 charset to vdp ram 
; 	+SetVector	.charset, adrl	;load charset
; 	lda	#<ADDRESS_GFX1_PATTERN
	
; 	ldy	#.WRITE_ADDRESS + >ADDRESS_GFX1_PATTERN
; 	ldx	#$08					

; 	+vdp_sreg
	
; 	ldy   #$00
; -  	lda   (adrl),y

; 	+vnops

; 	iny
; 	sta   a_vram
; 	bne   -
; 	inc   adrh
; 	dex
; 	bne   -
	


	lda #$01
	sta memctl


	; +vnops

	
	jmp dest
	
.align 255
; *=$1100
payload:
.incbin "kernel.bin"
payload_end:

.align 255
charset:
.include "charset_6x8.asm"
charset_end:


