.include "common.inc"
.include "kernel.inc"

.segment "CODE"

; 	system attribute has to be set on file system

; .pages = (.payload_end - .payload) / 256 + 1
src_ptr	= $e0
dst_ptr = $e2
		; copy kernel code to $f000
	
		lda #>payload
		sta src_ptr+1
		stz src_ptr

		lda #>kernel_start
		sta dst_ptr+1
		stz dst_ptr


;		SetVector payload, src_ptr
;		SetVector kernel_start, dst_ptr


		ldy #$00
loop:
		lda (src_ptr),y
		sta (dst_ptr),y
		iny
		bne loop
		lda src_ptr+1
		cmp #>payload_end
		bne @skip

		cpy #<payload_end
		bne @skip

@skip:
		inc src_ptr+1
		inc dst_ptr+1
		bne loop
end:
		
; loop:
; 
; @a:		lda payload
; @b:		sta kernel_start
; 
; 		inc @a+1
; 		inc @b+1
; 		bne loop
; 
; 		lda @a+2
; 		cmp #>payload_end
; 		bne @skip
; 		
; 		lda @a+1
; 		cmp #<payload_end
; 		bne @skip
; 		bra end
; @skip:
; 		inc @a+2
; 		inc @b+2
; 		bne loop
; 
; end:
; 
		lda #$01
		sta memctl


		; jump to reset vector
		jmp ($fffc)

.align 256
; *=$1100
payload:
.incbin "kernel.bin"
payload_end:
