.setcpu "65c02"
.include    "zeropage.inc"
.include    "debug.inc"

clockspeed = 8
user_isr 	        = $028e

.macro	printstring text
			jsr krn_primm
			.byte text
			.byte $0a,$0d,$00
.endmacro

.macro crlf
	lda #$0a		;\n already does the carriage return
	jsr krn_chrout
;	lda #$0d
;	jsr krn_chrout
.endmacro

ROM_OFF = 1<<0
BANK_SEL0 = 1<<1
BANK_SEL1 = 1<<2
BANK0 = 0
BANK1 = BANK_SEL0
BANK2 = BANK_SEL1
BANK3 = BANK_SEL1 | BANK_SEL0

.macro krn_ram_on
    +krn_rom_off
.endmacro

.macro krn_rom_off     ; disable ROM - enable RAM
    +krn_save_memctl
    lda #ROM_OFF
    sta memctl
.endmacro

.macro krn_bank0_on       ; enable bank 0 - ROM $0000-$1fff to $e000-$ffff
    +krn_save_memctl
    stz memctl
.endmacro

.macro krn_bank1_on       ; enable bank 1 - ROM $2000-$3fff to $e000-$ffff
    +krn_save_memctl
    lda #BANK1
    sta memctl
.endmacro

.macro krn_bank2_on       ; enable bank 2 - ROM $4000-$5fff to $e000-$ffff
    +krn_save_memctl
    lda #BANK2
    sta memctl
.endmacro

.macro krn_bank3_on        ; enable bank 3 - ROM $6000-$7fff to $e000-$ffff
    +krn_save_memctl
    lda #BANK3
    sta memctl
.endmacro

.macro krn_save_memctl    ; save memctl and a
    pha
    lda memctl
    pha
.endmacro

.macro krn_restore_memctl  ; restore memctl
    pla
    sta memctl
    pla
.endmacro 

.macro save
	pha
	phy
	phx
.endmacro

.macro restore
	plx
	ply
	pla
.endmacro

.macro Copy src, trgt, len

		ldx #len
:
		lda src,x
		sta trgt,x
		dex
		bpl :-

.endmacro

.macro toupper
	cmp #$60 ; Is lowercase?
	bcc :+
	and	#$DF
:
.endmacro

.macro tolower
	ora #$20
.endmacro
