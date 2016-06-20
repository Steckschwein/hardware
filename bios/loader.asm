.setcpu "65c02"


	lda #$80
	sta $0230

loop:
@a:	lda biosdata
@b:	sta $e000

	inc @a+1
	inc @b+1
	bne loop

	inc @a+2
	inc @b+2
	bne loop


;	+PrintString msgdone
	
	lda #$01
	sta $0230
	
	jmp ($fffc)
	
.align 256
biosdata:
.incbin "bios.bin"
