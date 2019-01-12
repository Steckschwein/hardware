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
.import opl2_detect
.import opl2_init

.export char_out=krn_chrout

.code
main:
		jsr opl2_init
		jsr opl2_detect
		bcc @load
		jsr krn_primm
		.byte "YM3526/YM3812 not available!",$0a,0
		jmp exit
@load:
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

		jsr krn_textui_crs_onoff
		jsr jch_fm_init

		sei
		copypointer user_isr, safe_isr
		SetVector player_isr, user_isr
		cli

:       keyin
		cmp #KEY_ESCAPE
		bne :-

		;TODO FIXME use ISR
		ldx #0
@fadeout:
		ldy #$40
:		dex
		bne :-
		dey 
		bne :-
		.import fm_master_volume
		inc fm_master_volume
		lda fm_master_volume
		cmp #$3f
		bne @fadeout
		
		sei
		copypointer safe_isr, user_isr
		jsr opl2_init
		cli
		
		jsr krn_textui_crs_onoff
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
		jsr printString
		jsr krn_primm
		.byte $0a,"Irq: ",0
		ldy #8
		lda d00file,y
		jsr hexout
		jsr krn_primm
		.byte $0a,"Spd: ",0
		ldy #8
		lda d00file,y
		jsr hexout
		rts

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
:		
		lda d00file, y
		cmp d00header,y
		bne :+
		iny 
		cpy #6
		bne :-
:
		rts

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
volume:	.res 1, $3f

player_isr:
		bit opl_stat
		bpl @is_irq_vdp

		lda #Cyan
		jsr vdp_bgcolor
		bra @exit
@is_irq_vdp:
		lda SYS_IRR
		bpl @exit

		lda #Dark_Yellow
		jsr vdp_bgcolor
@play:
		jsr jch_fm_play
@exit:

		lda #Medium_Green<<4|Transparent
		jsr vdp_bgcolor

		rts
		
ns_cl = 1000 / clockspeed
ns_sec = 1000000000
via_counter=clockspeed*1000000 / 70
            ;8.000.000 / 70 = 114285
safe_isr:   .res 2
.data
.export d00file
d00file:

.segment "STARTUP"