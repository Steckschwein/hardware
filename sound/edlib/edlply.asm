.setcpu "65c02"

.include "common.inc"
.include "fcntl.inc"
.include "kernel.inc"
.include "kernel_jumptable.inc"
.include "ym3812.inc"
.include "via.inc"
.include "vdp.inc"
.include "appstart.inc"
appstart $1000

.import vdp_bgcolor
.import hexout
.import jch_fm_init, jch_fm_play
.import opl2_init

.export char_out=krn_chrout

.globalzp ptr5
.zeropage
ptr5:   .res 2

.code
main:
 		;jsr jch_detect_chip
        ;bcc :+
        
        ;jsr krn_primm
        ;.byte "YM3526/YM3812 not available!",$0a,0
        ;jmp exit
        
        jsr loadfile
        beq :+
        pha
        jsr krn_primm
        .byte "i/o error occured: ",0
        pla
        jsr hexout
        lda #$0a
        jsr char_out
        jmp  exit
        
:       jsr isD00File
        beq :+
        jsr krn_primm
        .byte "not a D00 file",$0a,0
        jmp exit
        
:       
        jsr krn_primm
        .byte "edlib player v0.2 (somewhat optimized) by mr.mouse/xentax july 2017@",$0a,0
        jsr printMetaData

        ldy #0
        ldx #0
:       dex
        bne :-
        dey 
        bne :-
        
        sei
        jsr opl2_init
        jsr jch_fm_init
        copypointer $fffe, safe_isr
        SetVector player_isr, $fffe
        cli
        
:       keyin
        cmp #KEY_ESCAPE
        bne :-
        
        sei
        copypointer safe_isr, $fffe
        jsr opl2_init
        cli
exit:
        jmp (retvec)
     
printMetaData:
        jsr krn_primm
        .asciiz "Name: "
        ldy #$0b
        jsr printString
        jsr krn_primm
        .byte $0a,"Composer: ",0
        ldy #$2b
        jmp printString

printString:
        ldx #$20
:       lda d00file, y
        jsr char_out
        iny 
        dex
        bne :- 
        rts
        
isD00File:
        ldy #0
:       lda d00file, y
        cmp d00header,y
        bne :+
        iny 
        cpy #6
        bne :-
:       rts
        
d00header:
    .byte "JCH",$26,$2,$66
        
loadfile:
		lda paramptr
		ldx paramptr +1
		ldy #O_RDONLY
 		jsr krn_open
 		bne @l_exit
        stx fd
		SetVector d00file, read_blkptr
		jsr krn_read
        pha
        ldx fd
        jsr krn_close
        pla
        cmp #0
@l_exit:
        rts
fd:     .res 1
frames: .res 1, 50

player_isr:
        save
        cld	;clear decimal flag, maybe an app has modified it during execution
        bit opl_stat
        bpl @is_irq_vdp
        
        lda #Cyan
        jsr vdp_bgcolor
@is_irq_vdp:
        bit	a_vreg
        bpl @is_irq_via	   ; VDP IRQ flag set?
        
        lda #Dark_Yellow
        jsr vdp_bgcolor

        dec frames
        bne @exit
        lda #50
        sta frames
        
@is_irq_via:        
        bit via1ifr		; Interrupt from VIA?
        bpl @exit
        bit via1t1cl	; Acknowledge timer interrupt
        
        lda #<via_counter    
        sta via1t1cl            ; set low byte of count
        lda #>via_counter
        sta via1t1ch            ; set high byte of count
        
@exit:
        jsr jch_fm_play
        
        lda #Medium_Green<<4|Transparent
        jsr vdp_bgcolor
        
        restore
        rti
ns_cl = 1000 / clockspeed
ns_sec = 1000000000
via_counter=clockspeed*1000000 / 70
            ;8.000.000 / 70 = 114285
safe_isr:   .res 2
.data
.export d00file
d00file:

.segment "STARTUP"