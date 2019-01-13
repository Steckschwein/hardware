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
.import opl2_detect, opl2_init, opl2_reg_write
.import opl2_delay_register

.export char_out=krn_chrout

.code
main:
		jsr opl2_detect
		clc
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

		freq=70
		t2cycles=275
		;jsr opl2_delay_register
		ldx #opl2_reg_t2	; t2 timer value
		lda #($ff-(1000000 / freq / t2cycles))	; 1s => 1.000.000µs / 70 (Hz) / 320µs = counter value => timer is incremental, irq on overflow so we have to $ff - counter value
		jsr opl2_reg_write
		jsr reset_irq
		jsr restart_timer
		
		cli
		
@keyin: keyin
		cmp #'p'
		bne @key_esc
		lda #01
		eor player_state
		sta player_state
		beq :+
		jsr krn_primm
		.byte $0a,"Pause...",0
		bra @keyin
:		jsr krn_primm
		.byte $0a,"Play...",0
		bra @keyin
@key_esc:
		cmp #KEY_ESCAPE		
		beq @exit_player
		bra @keyin

@exit_player:;TODO FIXME use ISR
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
		cli
		
exit:
		jsr opl2_init
		jsr krn_textui_init
		jmp (retvec)
		
reset_irq:
		ldx #opl2_reg_ctrl
		lda #$80
		jmp opl2_reg_write

restart_timer:
		ldx #opl2_reg_ctrl
		lda #$42	; t2
		jmp opl2_reg_write

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
;		jsr krn_primm
;		.byte $0a,"Spd: ",0
;		ldy #8
;		lda d00file,y
;		jsr hexout
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
		bit SYS_IRR
		bvc @exit
		; do write operations on ym3812 within a user isr directly after reading opl_stat here, "is too hard", we have to delay at least register wait ;)		
		jsr opl2_delay_register
		jsr reset_irq
;		jsr opl2_delay_register
		jsr restart_timer
;		lda #Light_Red
;		jsr vdp_bgcolor
		lda player_state
		bne @exit
		jsr jch_fm_play
@exit:
		lda #Medium_Green<<4|Transparent
		jsr vdp_bgcolor

		rts
		
safe_isr:   .res 2
player_state: .res 1,0
.data
.export d00file
d00file:

.segment "STARTUP"