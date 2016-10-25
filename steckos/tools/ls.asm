dir_attrib_mask		= $0a
.segment "CODE"
.include "../kernel/kernel.inc"
.include "../kernel/kernel_jumptable.inc"
.include "../kernel/fat32.inc"
.include "../asminc/filedes.inc"
.include "ls.inc"

.export print_filename
.import dir_show_entry
main:

		lda #$04
		sta cnt
		

l1:
		crlf
		SetVector pattern, filenameptr

		lda (paramptr)
		beq @l2
		copypointer paramptr, filenameptr

@l2:
        ldx #FD_INDEX_CURRENT_DIR
		jsr krn_find_first
        lda errno
        beq @l2_1
        printstring "i/o error"
        jmp (retvec)
        
@l2_1:	bcs @l4
		bra @l5
		; jsr .dir_show_entry
@l3:
        ldx #FD_INDEX_CURRENT_DIR
		jsr krn_find_next
		bcc @l5
@l4:	
		lda (dirptr)
		cmp #$e5
		beq @l3

		ldy #DIR_Attr
		lda (dirptr),y

		bit #dir_attrib_mask ; Hidden attribute set, skip
		bne @l3

		
		jsr dir_show_entry

		jsr krn_getkey
		cmp #$03 ; CTRL-C?
		beq @l5
		bra @l3
@l5:


		jmp (retvec)


; dir_show_entry:
; 		pha

; 		dec cnt 
; 		bne @l1
; 		crlf
; 		lda #$03
; 		sta cnt	
; @l1:
; 		jsr print_filename
; 		lda #' '
; 		jsr krn_chrout
; 		pla

; 		rts


print_filename:
		ldy #DIR_Name
@l1:	lda (dirptr),y
		jsr krn_chrout
		iny
		cpy #$0b
		bne @l1
		rts
 ; Lookup table for decimal to ASCII
dec_tbl:			.byte 128,160,200

pattern:			.byte "*.*",$00


