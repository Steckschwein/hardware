.setcpu "65C02"
.segment "CODE"
.include "kernel.inc"
.include "vdp.inc"
; 	system attribute has to be set on file system
memctl = $0230
dest = $f000

.macro	vnops
		nop			;2cl
		nop			;2cl
		nop
		nop
		nop
		nop
		nop
		nop
.endmacro

; .pages = (.payload_end - .payload) / 256 + 1

		; copy kernel code to $f000
loop:

@a:		lda payload
@b:		sta dest

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
		lda		#v_reg1_16k	;enable 16K ram, disable screen
		sta 	a_vreg
		vnops
		lda	  	#v_reg1
		sta   	a_vreg
		

		; copy 6x8 charset to vdp ram 
		SetVector	charset, adrl	;load charset
		lda	#<ADDRESS_GFX1_PATTERN
		
		ldy	#WRITE_ADDRESS + >ADDRESS_GFX1_PATTERN
		ldx	#$08					

		vdp_sreg
		
		ldy   #$00
@l1:  	lda   (adrl),y

		vnops

		iny
		sta   a_vram
		bne   @l1
		inc   adrh
		dex
		bne   @l1
		

		lda #$01
		sta memctl


		; jump to reset vector
		jmp ($fffc)
		
.align 256
; *=$1100
payload:
.incbin "kernel.bin"
payload_end:

.align 256
charset:
.include "charset_6x8.asm"
charset_end:
