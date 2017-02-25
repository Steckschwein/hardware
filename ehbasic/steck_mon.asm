
; minimal monitor for EhBASIC and 6502 simulator V1.05
; Modified to support the Replica 1 by Jeff Tranter <tranter@pobox.com>
; Steckschwein

; To run EhBASIC on the simulator load and assemble [F7] this file, start the simulator
; running [F6] then start the code with the RESET [CTRL][SHIFT]R. Just selecting RUN
; will do nothing, you'll still have to do a reset to run the code.

.include "../steckos/kernel/kernel.inc"
.include "../steckos/kernel/kernel_jumptable.inc"
.include "../steckos/kernel/fat32.inc"

.include "basic.asm"

ESC = $1B        ; Escape character
CR  = $0D        ; Return character
LF  = $0A        ; Line feed character

; put the IRQ and MNI code in RAM so that it can be changed
IRQ_vec	= VEC_SV+2		; IRQ code vector
NMI_vec	= IRQ_vec+$0A	; NMI code vector

; reset vector points here

RES_vec:
	CLD				; clear decimal mode
	LDX	#$FF			; empty stack
	TXS				; set the stack

; set up vectors and interrupt code, copy them to page 2

 	LDY	#END_CODE-LAB_vec	; set index/count
LAB_stlp:
 	LDA	LAB_vec-1,Y		; get byte from interrupt code
    	STA	VEC_IN-1,Y		; save to RAM
 	DEY				    ; decrement index/count
 	BNE	LAB_stlp		; loop if more to do
    
	JMP	LAB_COLD		; do EhBASIC cold start

io_error:
		pha
		jsr	krn_primm
		.asciiz "io error: "
		pla
		jsr krn_hexout
		rts

psave:

		save

		lda Bpntrl
		ldx Bpntrh

		jsr krn_open
		beq @go
		jsr io_error
		restore
		rts
@go:
		phx
		jsr pscan
		ldy #$00
		lda Itempl
		sta (Itempl),y
		iny
		lda Itemph
		sta (Itempl),y

		lda Smemh
		sta write_blkptr + 1
		lda Smeml
		sta write_blkptr + 0

		plx

		sec
		lda Itempl
		sbc Smeml
		sta fd_area + F32_fd::FileSize + 0,x

		lda Itemph
		sbc Smemh
		sta fd_area + F32_fd::FileSize + 1,x

		lda #$00
		sta fd_area + F32_fd::FileSize + 2,x
		sta fd_area + F32_fd::FileSize + 3,x

		jsr krn_write
		jsr krn_close
		
@exit_save:
		restore
		rts

pload:
		save


		lda Bpntrl
		ldx Bpntrh

;		lda #<filename
;		ldx #>filename
		jsr krn_open
		beq @go
@pload_err:
		jsr io_error
		restore
		rts
@go:
		jsr krn_primm
		.asciiz "Loading from $"

		lda	Smemh
		sta read_blkptr + 1
		jsr krn_hexout

		lda	Smeml
		sta read_blkptr + 0
		jsr krn_hexout

		jsr krn_primm
		.asciiz " to $"

		jsr krn_read
		lda errno
		bne @pload_err

		jsr krn_close
		lda errno
		bne @pload_err

		jsr	pscan
		lda	Itempl
		sta	Svarl
		sta	Sarryl
		sta	Earryl
		lda	Itemph
		sta	Svarh
		sta	Sarryh
		sta	Earryh
		jsr krn_hexout
		lda Itempl
		jsr krn_hexout

		jsr krn_primm
		.byte $0a, "Ok", $0a, $00
		restore
		JMP   LAB_1319		
pscan:
		lda	Smeml
      		sta	Itempl
     	 	lda	Smemh
     	 	sta	Itemph
pscan1:		ldy   #$00
		lda   (Itempl),y
		bne   pscan2
		iny   
		lda   (Itempl),y
		bne   pscan2
		clc
		lda   #$02
		adc   Itempl
		sta	Itempl
		lda	#$00
		adc	Itemph
		sta	Itemph
		rts
pscan2:		ldy   #$00
		lda	(Itempl),y
		tax
		iny
		lda	(Itempl),y
		sta	Itemph
		stx	Itempl
		bra	pscan1


; vector tables

LAB_vec:
	.word	krn_getkey		; byte in
	.word	krn_chrout		; byte out
	.word	pload		; load vector for EhBASIC
	.word	psave		; save vector for EhBASIC

; EhBASIC IRQ support

IRQ_CODE:
	PHA				; save A
    	lda #'i'
    	jsr V_OUTP
	LDA	IrqBase		; get the IRQ flag byte
	LSR				; shift the set b7 to b6, and on down ...
	ORA	IrqBase		; OR the original back in
	STA	IrqBase		; save the new IRQ flag byte
	PLA				; restore A
	RTI

; EhBASIC NMI support

NMI_CODE:
	PHA				; save A
    	lda #'n'
    	jsr V_OUTP
	LDA	NmiBase		; get the NMI flag byte
	LSR				; shift the set b7 to b6, and on down ...
	ORA	NmiBase		; OR the original back in
	STA	NmiBase		; save the new NMI flag byte
	PLA				; restore A
	RTI

END_CODE:

;LAB_mess:
	;.byte	$0D,$0A,"6502 EhBASIC [C]old/[W]arm ?",$00
					; sign on string

filename:	.asciiz	"FILE0000.DAT"
; system vectors
	;.org	$FFFA
	;.word	NMI_vec		; NMI vector
	;.word	RES_vec		; RESET vector
	;.word	IRQ_vec		; IRQ vector
