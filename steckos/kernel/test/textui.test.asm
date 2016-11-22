;text_mode_40 = 1

segment .KERNEL

    jmp main
	
main
    sei
    +SetVector .test_irq, irqvec

    jsr	.textui_init0
    
    cli
    
    ldx #02
    ldy #01
    jsr .textui_crsxy
    
-   
    jsr .keyin
    jsr .textui_out
    
    bra -
    
.test_irq
	+save

	bit	a_vreg
	bpl ++	   ; VDP IRQ flag set?

	jsr	.textui_update_screen
	
++
	+restore
	rti

.keyin
-	jsr .getkey
	cmp #$00
	beq -
	rts 
    
.getkey
	jmp getkey