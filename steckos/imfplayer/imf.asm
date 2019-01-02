; MIT License
;
; Copyright (c) 2018 Thomas Woinke, Marko Lauke, www.steckschwein.de
;
; Permission is hereby granted, free of charge, to any person obtaining a copy
; of this software and associated documentation files (the "Software"), to deal
; in the Software without restriction, including without limitation the rights
; to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
; copies of the Software, and to permit persons to whom the Software is
; furnished to do so, subject to the following conditions:
;
; The above copyright notice and this permission notice shall be included in all
; copies or substantial portions of the Software.
;
; THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
; IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
; FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
; AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
; LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
; OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
; SOFTWARE.

.include "kernel.inc"
.include "kernel_jumptable.inc"
.include "via.inc"
.include "common.inc"
.include "fcntl.inc"
.include "ym3812.inc"

.include "appstart.inc"
appstart $1000

.importzp   ptr1, tmp1

.code

CPU_CLOCK=clockspeed * 1000000

imf_ptr   = ptr1
imf_ptr_h = imf_ptr + 1

delayl    = tmp1
delayh    = delayl + 1

.import opl2_init, opl2_delay_register

main:
;		jmp play
;		SetVector test_filename, filenameptr
;		copypointer paramptr, filenameptr

 		ldy #$00
@l1:
		lda (paramptr),y
 		beq @l2

 		iny
 		bra @l1
@l2:
 		dey
 		lda (paramptr),y
 		and #%11011111
 		cmp #'F'
 		beq @l3
 		jmp error
@l3:

		dey
		lda (paramptr),y
		and #%11011111
		cmp #'L'
		bne @l4

		dey
		lda (paramptr),y
		and #%11011111
		cmp #'W'
		bne @l4

		lda #$04
		sta temponr

@l4:
		lda paramptr
		ldx paramptr +1
		ldy #O_RDONLY
 		jsr krn_open
 		beq @l5
		jmp error
@l5:
        stx fd
		SetVector imf_data, read_blkptr

		jsr krn_read
 		beq @l6
 		jmp error
@l6:
		jsr krn_getfilesize

        clc
		adc #<imf_data
 		sta imf_end

		txa

 		adc #>imf_data
 		sta imf_end+1

        jsr fclose

play:
		SetVector	imf_data, imf_ptr
		stz delayl
		stz delayh

		jsr opl2_init

		sei

		ldx temponr
		lda tempo+0,x

		sta via1t1cl
		lda tempo+1,x
		sta via1t1ch            ; set high byte of count

		lda #%11000000
		sta via1ier             ; enable VIA1 T1 interrupt

		lda #%01000000		; T1 continuous, PB7 disabled
		ora via1acr
		sta via1acr

		copypointer $fffe, old_isr
		SetVector player_isr, $fffe

		cli

loop:
		bit state
		bmi exit

		jsr krn_getkey
		cmp #$03
		beq exit
		cmp #$1b ; escape
		beq exit

		bra loop

exit:
        jsr krn_primm
		.byte " done.",$0a,0

		sei

        lda #%01000000
		sta via1ier

		copypointer old_isr, $fffe

		lda via1acr
		and #%10111111
		sta via1acr

        jsr opl2_init   ; reset opl

		cli
		jmp (retvec)

player_isr:
		pha
		phy

		bit via1ifr		; Interrupt from VIA?
		bpl @isr_end

		bit via1t1cl	; Acknowledge timer interrupt by reading channel low


		; delay counter zero?
		lda delayh
		clc
		adc delayl
		beq @l1

		; if no, 16bit decrement and exit routine
		dec16 delayh

		bra @isr_end
@l1:

		ldy #$00
		lda (imf_ptr),y
		sta opl_stat

		iny
		lda (imf_ptr),y

		jsr opl2_delay_register

		sta opl_data

		iny
		lda (imf_ptr),y
		sta delayh

		iny
		lda (imf_ptr),y
		sta delayl

	 	; song data end reached? then set state to 80 so loop will terminate
		lda imf_ptr_h
		cmp imf_end+1
		bne @l3
		lda imf_ptr
		cmp imf_end+0
		bne @l3

		lda #$80
		sta state

		bra @isr_end
@l3:

		;advance pointer by 4 bytes
		clc
		lda #$04
		adc imf_ptr
		sta imf_ptr
		bcc @isr_end
		inc imf_ptr_h
@isr_end:
		; jump to kernel isr
		ply
		pla
		jmp (old_isr)

error:
    and #$0f
    ora #'0'
	jsr krn_chrout
	jsr krn_primm
	.asciiz "load error"
end:
    jsr fclose
	jmp (retvec)

fclose:
    ldx fd
    beq :+
    jsr krn_close
    stz fd
:   rts

tempo:
 	; tempo is one of 280Hz (DN2), 560Hz (imf), 700Hz (.wlf)
	.word (CPU_CLOCK/280)
	.word (CPU_CLOCK/560)
	.word (CPU_CLOCK/700)
temponr:
	.byte $02
;test_filename:  .asciiz "pacman.wlf"
state:	    .byte $00
old_isr:	.word $ffff
imf_end:	.word $ffff
fd: .res 1, 0

.data
imf_data:

.segment "STARTUP"
