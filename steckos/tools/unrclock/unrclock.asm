.setcpu "65c02"

.include "common.inc"
.include "kernel.inc"
.include "kernel_jumptable.inc"
.include "rtc.inc"
.include "vdp.inc"
.include "appstart.inc"
appstart $1000

.importzp ptr1,ptr2
.importzp tmp1,tmp2,tmp3,tmp4

.import vdp_bgcolor
.import vdp_mc_on
.import vdp_mc_blank
.import vdp_fill

clock_update_trigger=tmp1
color=tmp3
clock_position_trigger=tmp4

color_bg=Transparent
color_off=Gray
color_sec=Dark_Blue
color_min_l=Magenta
color_min_h=Medium_Green
color_hour_l=Light_Blue
color_hour_h=Medium_Red

.code
main:
        sei
        jsr krn_textui_disable
        jsr clock_init
        
        copypointer user_isr, safe_isr
        SetVector clock_isr, user_isr
        
        stz clock_update_trigger
        stz clock_position_trigger
        
        cli
        
@main_loop:
        lda clock_update_trigger
        beq @main_loop
        jsr clock_update
        jsr clock_position
        stz clock_update_trigger
        
        jsr	krn_getkey
        bne exit
        bra @main_loop
exit:                
        sei
        copypointer safe_isr, user_isr
		jsr	krn_textui_init
;        jsr krn_textui_enable
        cli

        jmp (retvec)

clock_position:
        lda rtc_systime_t+time_t::tm_sec
        bit #$0f
        beq :+
        stz clock_position_trigger
:       bit #$0f
        bne @l_end
@l_update:
        lda clock_position_trigger
        bne @l_end
        inc clock_position_trigger
        jsr rnd
        and #%00000011; multiple of 32
        adc #(WRITE_ADDRESS + >(ADDRESS_GFX_MC_PATTERN))
        sta vaddr_new+1
        ldx #(last_rtc_end-last_rtc-1)
@l_clr: stz last_rtc,x
        dex
        bpl @l_clr
@l_end:
        rts
        
clock_init:
        jsr vdp_mc_blank
        jsr vdp_mc_on
        rts

clock_update:
        jsr clock_reset
        jsr clock_calc
        jsr clock_draw
                
        rts
      
clock_draw:
        jsr clock_draw_sec
        
        SetVector color_mask_l, ptr1
        lda #color_min_l<<4 | color_min_l
        sta tmp2      ; color
        lda #($10*8)
        ldy #<(tab_min_l-tab_lights)    ; offset min low
        jsr clock_draw_3x3_block

        lda #color_hour_h<<4 | color_hour_h
        sta tmp2
        lda #0
        ldx #2
        ldy #<(tab_hour_h-tab_lights)   ; offset hours high
        jsr clock_draw_3x3_block_n
        
        SetVector color_mask_r, ptr1
        lda #color_min_h<<4 | color_min_h
        sta tmp2
        lda #(9*8)
        ldy #<(tab_min_h-tab_lights)    ; offset min high
        jsr clock_draw_3x3_block
        
        lda #color_hour_l<<4 | color_hour_l
        sta tmp2
        lda #(2*8)
        ldy #<(tab_hour_l-tab_lights)   ; offset hours low
        jsr clock_draw_3x3_block
        rts


clock_draw_3x3_block: ;
        ldx #8        ; 0-8, 1-9 blocks
clock_draw_3x3_block_n:        
        sta tmp1      ; block offset
@loop:  lda tab_lights, y
        beq @l_skip
        
        lda clock_ptr_tab_block_h, x
        sta ptr2+1
        
        lda clock_ptr_tab_block_1_l, x
        jsr clock_draw_row_3x        
        inc ptr1
        
        lda clock_ptr_tab_block_2_l, x
        jsr clock_draw_row_3x
        dec ptr1
@l_skip:
        iny
        dex
        bpl @loop
        
        rts
        
clock_draw_row_3x:
        clc
        adc tmp1
        sta ptr2
        
        lda tmp2    ; color
        and (ptr1)  ; ... and mask
        
        sta (ptr2)
        inc ptr2
        sta (ptr2)
        inc ptr2
        sta (ptr2)
        rts

clock_draw_sec:
        ldx #58 ;59 states - 0-58
:       lda tab_sec, x
        beq :+
        
        lda clock_ptr_tab_l_sec, x
        sta ptr2
        lda clock_ptr_tab_h_sec, x
        sta ptr2+1        
        lda #Transparent<<4|color_sec
        sta (ptr2)
:        
        dex
        bpl :--
        
        rts

        
clock_calc:
        ldy #0  ; offset into last rtc
        
        lda #59 ;sequence max
        sta tmp2
        SetVector tab_sec, ptr1
        lda rtc_systime_t+time_t::tm_sec
        jsr rnd_sequence

        lda #9 ;sequence max - 9 blocks
        sta tmp2
        
        SetVector tab_min_l, ptr1
        lda rtc_systime_t+time_t::tm_min
        jsr bin2dec
        jsr rnd_sequence_l_nibble

        SetVector tab_min_h, ptr1
        jsr rnd_sequence_h_nibble

        SetVector tab_hour_l, ptr1
        lda rtc_systime_t+time_t::tm_hour
        jsr bin2dec
        jsr rnd_sequence_l_nibble
        
        lda #3 ;sequence max - 1-3 blocks
        sta tmp2
        SetVector tab_hour_h, ptr1
        jsr rnd_sequence_h_nibble

        rts

rnd_sequence_l_nibble:
        tax
        and #$0f
        bra rnd_sequence
        
rnd_sequence_h_nibble:
        txa
        lsr
        lsr
        lsr
        lsr
        
 ; convert number "n" into a random sequence of 0 and 1 with length "n"
rnd_sequence:
        cmp last_rtc, y ; has changed?
        beq @l_end
        sta last_rtc, y
        
        phx
        phy
        tax             ; "n" as loop counter to x
        
        ldy tmp2        ; erase current tab
        dey
        lda #0
:       sta (ptr1), y
        dey
        bpl :-       
        
        cpx #0                  ; zero number?     
        beq @l_end_restore      ; skip and leave an empty sequence
@l_rnd:
        jsr rnd
@l_mod:
        cmp tmp2
        bcc @l_ix
        sbc tmp2
        bra @l_mod
@l_ix:
        tay
@l_tst:        
        lda (ptr1), y
        beq @l_set
        iny
        cpy tmp2
        bne @l_tst
        ldy #0
        bra @l_tst
@l_set:
        lda #1
        sta (ptr1), y
        dex
        bne @l_rnd
@l_end_restore:
        ply
        plx
@l_end:
        iny ; update y into last_rtc
        rts

;convert A to packed decimal (MAX 99)       
bin2dec:
        pha
        lsr 
        lsr 
        lsr  
        lsr 
        tax
        sed
        pla
        and #$0f
        pha
        lda bindech,x
        clc
        plx
        adc bindecl,x
        cld
        rts
bindecl: 
        .byte $00,$01,$02,$03,$04,$05,$06,$07,$08,$09,$10,$11,$12,$13,$14,$15
bindech:
        .byte $00,$16,$32,$48,$64,$80,$96 

clock_reset:        
        lda #Transparent<<4|color_off
        sta color
        ldy #0
        jsr clock_reset_row_upper
        jsr clock_reset_row_lower
        ldy #2
        jsr clock_reset_row_upper
        jsr clock_reset_row_lower
        ldy #4
        jsr clock_reset_row_upper
        ldy #6
        jsr clock_reset_row_upper
        
        lda #Transparent<<4|Transparent
        sta color
        ldy #1
        jsr clock_reset_row_upper  
        jsr clock_reset_row_lower
        ldy #5
        jsr clock_reset_row_upper
        rts
        
clock_reset_row_upper:
        lda #color_off<<4|color_off            ; ## => 1 byte - 2 pixels in mc
        sta clock_data_row1+$00*8,y
        sta clock_data_row1+$03*8,y
        sta clock_data_row1+$05*8,y
        sta clock_data_row1+$07*8,y
        sta clock_data_row1+$0a*8,y
        sta clock_data_row1+$0c*8,y
        sta clock_data_row1+$0e*8,y
        sta clock_data_row1+$10*8,y
        sta clock_data_row1+$12*8,y
        sta clock_data_row1+$14*8,y
        lda #color_off<<4|Transparent          ; #.
        sta clock_data_row1+$01*8,y
        sta clock_data_row1+$11*8,y
        sta clock_data_row1+$13*8,y
        sta clock_data_row1+$15*8,y
        lda #Transparent<<4|color_off           ; .#
        sta clock_data_row1+$02*8,y
        sta clock_data_row1+$04*8,y
        sta clock_data_row1+$06*8,y
        sta clock_data_row1+$09*8,y
        sta clock_data_row1+$0b*8,y
        sta clock_data_row1+$0d*8,y
        lda color
        sta clock_data_row1+$16*8,y
        sta clock_data_row1+$17*8,y
        sta clock_data_row1+$18*8,y
        sta clock_data_row1+$19*8,y
        sta clock_data_row1+$1a*8,y
        sta clock_data_row1+$1b*8,y
        sta clock_data_row1+$1c*8,y
        sta clock_data_row1+$1d*8,y
        sta clock_data_row1+$1e*8,y
        sta clock_data_row1+$1f*8,y
        rts

clock_reset_row_lower:
        lda #color_off<<4|color_off            ; ## => 1 byte - 2 pixels in mc
        sta clock_data_row2+$00*8,y
        sta clock_data_row2+$03*8,y
        sta clock_data_row2+$05*8,y
        sta clock_data_row2+$07*8,y
        sta clock_data_row2+$0a*8,y
        sta clock_data_row2+$0c*8,y
        sta clock_data_row2+$0e*8,y
        sta clock_data_row2+$10*8,y
        sta clock_data_row2+$12*8,y
        sta clock_data_row2+$14*8,y
        lda #color_off<<4|Transparent          ; #.
        sta clock_data_row2+$01*8,y
        sta clock_data_row2+$11*8,y
        sta clock_data_row2+$13*8,y
        sta clock_data_row2+$15*8,y
        lda #Transparent<<4|color_off           ; .#
        sta clock_data_row2+$02*8,y
        sta clock_data_row2+$04*8,y
        sta clock_data_row2+$06*8,y
        sta clock_data_row2+$09*8,y
        sta clock_data_row2+$0b*8,y
        sta clock_data_row2+$0d*8,y
        lda color
        sta clock_data_row2+$16*8,y
        sta clock_data_row2+$17*8,y
        sta clock_data_row2+$18*8,y
        sta clock_data_row2+$19*8,y
        sta clock_data_row2+$1a*8,y
        sta clock_data_row2+$1b*8,y
        sta clock_data_row2+$1c*8,y
        sta clock_data_row2+$1d*8,y
        sta clock_data_row2+$1e*8,y
        sta clock_data_row2+$1f*8,y      
        rts
        
clock_isr:
        lda #Dark_Green<<4 | Cyan
;        jsr vdp_bgcolor

        inc clock_update_trigger

        lda vaddr
        cmp vaddr_new
        bne @l_erase
        ldy vaddr+1
        cpy vaddr_new+1
        beq @l_update
@l_erase:   ; clear clock at old position
            vdp_sreg
            lda #Transparent<<4|Transparent
            ldx #2
            jsr vdp_fill
            copypointer vaddr_new, vaddr
            
@l_update:
        SetVector clock_data, ptr1
        lda vaddr
        ldy vaddr+1
        vdp_sreg
        
        ldx #<(32*8)
        jsr copy_vram
        inc ptr1+1
        ldx #<(32*8)
        jsr copy_vram
        
        lda #Dark_Green<<4| Transparent
        jsr vdp_bgcolor
                
        
        rts
        
copy_vram:
        ldy #0
:
        vdp_wait_l 12
        lda (ptr1),y
        sta a_vram
        iny
        dex 
        bne :-
        rts
        
rnd:
        lda seed
        beq doEor
        asl
        beq noEor ;if the input was $80, skip the EOR
        bcc noEor
doEor:
        eor #$1d
noEor:
        sta seed
        rts
        
.data
clock_data: 
clock_data_row1:
        .res 32 * 8,Transparent<<4|Transparent   ; 6 mc pixel rows + 2 spacer
clock_data_row2:
        .res 32 * 8,Transparent<<4|Transparent   ; 3 mc pixel rows

clock_ptr_tab_l_sec:
        .repeat 6, row
            .repeat 10, col
                .byte <clock_data + ($16+col)*8+((2*row) .mod 8)   ;$16 offset
            .endrepeat
        .endrepeat
        
clock_ptr_tab_h_sec:
        .repeat 6, row
            .repeat 10, col
                .byte <(>clock_data + >($16+col)*8+((2*row) / 8))   ;$16 offset
            .endrepeat
        .endrepeat

clock_ptr_tab_block_1_l:
        .repeat 3, col
            .byte <clock_data+(col)*2*8
            .byte <clock_data+(col)*2*8+4
            .byte <clock_data+(col)*2*8
        .endrepeat
clock_ptr_tab_block_2_l:
        .repeat 3, col
            .byte <clock_data+(col)*2*8+8
            .byte <clock_data+(col)*2*8+12
            .byte <clock_data+(col)*2*8+8
        .endrepeat
                
clock_ptr_tab_block_h:
        .repeat 3, col
            .byte >clock_data_row1
            .byte >clock_data_row1
            .byte >clock_data_row2
            .byte >clock_data_row1
            .byte >clock_data_row1
            .byte >clock_data_row2
        .endrepeat
        
color_mask_r:
        .byte color_bg<<4 | %1111
color_mask_l:
        .byte %11111111, %1111<<4 | color_bg

tab_lights:
tab_sec:    .res 59
tab_min_l:  .res 9
tab_min_h:  .res 9
tab_hour_l: .res 9
tab_hour_h: .res 3
tab_lights_end:

last_rtc:      
        .res 1 ; sec
        .res 2 ; min 
        .res 2 ; hour
last_rtc_end:

vaddr:       .byte <ADDRESS_GFX_MC_PATTERN, WRITE_ADDRESS + >(ADDRESS_GFX_MC_PATTERN)
vaddr_new:   .byte <ADDRESS_GFX_MC_PATTERN, WRITE_ADDRESS + >(ADDRESS_GFX_MC_PATTERN)

safe_isr:  .res 2
seed: .res 1, 123

.segment "STARTUP"