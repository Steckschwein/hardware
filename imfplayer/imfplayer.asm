
.include "../steckos/kernel/kernel.inc"
.include "../steckos/kernel/kernel_jumptable.inc"
.include "../steckos/kernel/via.inc"
.include "ym3812.inc"

.macro dec16 word 
        lda word
        bne :+
        dec word+1
:       dec word
.endmacro



CPU_CLOCK=clockspeed * 1000000

imf_ptr   = $a0
imf_ptr_h = imf_ptr + 1

delayl    = $a2
delayh    = delayl + 1

.import init_opl2,  opl2_delay_register

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

 		jsr krn_open
 		beq @l5
		jmp error
@l5:


		SetVector imf_data, sd_read_blkptr


		crlf
		jsr krn_primm
 		.asciiz "Loading from $"

		lda #>imf_data
		jsr krn_hexout
		lda #<imf_data
		jsr krn_hexout
	
		jsr krn_read    
		lda errno
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

 		jsr krn_primm
 		.asciiz " to $"

		lda imf_end+1
		jsr krn_hexout
		lda imf_end+0
		jsr krn_hexout

		crlf

		jsr krn_close

play:
		SetVector	imf_data, imf_ptr
		stz delayl
		stz delayh

		jsr init_opl2

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
		cmp #'x'
		beq exit

		bra loop


exit:   
	  	jsr init_opl2

		jsr krn_primm
		.asciiz " done."
		crlf

		sei

		lda #%01000000
		sta via1ier	


		copypointer old_isr, user_isr


		lda via1acr
		and #%10111111
		sta via1acr

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
;		jsr krn_hexout

;		inc crs_x

		iny
		lda (imf_ptr),y

		jsr opl2_delay_register

		sta opl_data		
;		jsr krn_hexout


		; jsr opl2_delay_data

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
		bcc @l4
		inc imf_ptr_h
@l4:	
		lda #10
		jsr krn_chrout
		lda imf_ptr_h
		jsr krn_hexout
		lda imf_ptr
		jsr krn_hexout
@isr_end:
		; jump to kernel isr
		ply
		pla
		jmp (old_isr)

error:
	jsr krn_hexout
	jsr krn_primm
	.asciiz "load error"
end:	
	jmp (retvec)

tempo:
 	; tempo is one of 280Hz (DN2), 560Hz (imf), 700Hz (.wlf) 
	.word (CPU_CLOCK/280)
	.word (CPU_CLOCK/560)
	.word (CPU_CLOCK/700)
temponr:
	.byte $02
;test_filename:  .asciiz "pacman.wlf"
state:	.byte $00
old_isr:	.word $ffff
imf_end:	.word $ffff
;delayl:		.word $0000
;delayh = delayl + 1
imf_data = $1230	