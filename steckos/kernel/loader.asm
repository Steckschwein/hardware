.setcpu "65C02"
.include "common.inc"
.include "kernel.inc"

.segment "CODE"

; 	system attribute has to be set on file system

; .pages = (.payload_end - .payload) / 256 + 1

		; copy kernel code to $f000
loop:

@a:		lda payload
@b:		sta kernel_start

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

		lda #$01
		sta memctl


		; jump to reset vector
		jmp ($fffc)

.align 256
; *=$1100
payload:
.incbin "kernel.bin"
payload_end:

;.segment "KERNEL"
;segment "VECTORS"
;segment "JUMPTABLE"
