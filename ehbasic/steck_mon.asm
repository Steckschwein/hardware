
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

;IN    = $0200    ; Buffer used by GetLine. From $0200 through $027F (shared with Woz Mon)
IN    =  $c000

; put the IRQ and MNI code in RAM so that it can be changed
IRQ_vec	= VEC_SV+2		; IRQ code vector
NMI_vec	= IRQ_vec+$0A	; NMI code vector

; setup for the 6502 simulator environment

; IO_AREA	= $0200		; set I/O area for this monitor

; now the code. all this does is set up the vectors and interrupt code
; and wait for the user to select [C]old or [W]arm start. nothing else
; fits in less than 128 bytes

;	.org	$FF80			; pretend this is in a 1/8K ROM

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
    
; now do the signon message, Y = $00 here
;LAB_signon:
;	LDA	LAB_mess,Y		; get byte from sign on message
;	BEQ	LAB_nokey		; exit loop if done
;	JSR	V_OUTP		    ; output character
;	INY				    ; increment index
;	BNE	LAB_signon		; loop, branch always
    
;LAB_nokey:
;	JSR	V_INPT          ; call scan input device   
;	lda #'c'            ; by cold start question
    
;    Beq	LAB_nokey		; loop if no key
    
;	AND	#$DF			; mask xx0x xxxx, ensure upper case
;	CMP	#'W'			; compare with [W]arm start
;	BEQ	LAB_dowarm		; branch if [W]arm start

;	CMP	#'C'			; compare with [c]old start
;	BNE	RES_vec		    ; loop if not [c]old start
            
	JMP	LAB_COLD		; do EhBASIC cold start

;LAB_dowarm:
;	JMP	LAB_WARM		; do EhBASIC warm start

psave:
		lda #<filename
		ldx #>filename
		jsr krn_open
		beq @go
		rts
@go:
		phx
		jsr	pscan
		ldy	#$00
		lda	Itempl
		sta	(Itempl),y
		iny
		lda	Itemph
		sta	(Itempl),y
		lda	Smemh
		sta write_blkptr + 1
		lda	Smeml
		sta write_blkptr + 0

		plx

		sec
		lda	Itempl
		sbc	Smeml

        	sta fd_area + F32_fd::FileSize + 0,x

		lda	Itemph
		sbc	Smemh
        	sta fd_area + F32_fd::FileSize + 1,x

        	lda #$00
        	sta fd_area + F32_fd::FileSize + 3,x
        	sta fd_area + F32_fd::FileSize + 2,x


		jsr krn_write
		jsr krn_close
		
		rts

pload:		
		jsr	pscan
		lda	Itempl
		sta	Svarl
		sta	Sarryl
		sta	Earryl
		lda	Itemph
		sta	Svarh
		sta	Sarryh
		sta	Earryh
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
