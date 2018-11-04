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

.setcpu "65c02"
.include    "zeropage.inc"
.include    "debug.inc"

kernel_start = $e800
clockspeed   = 8
user_isr     = $028a

.macro	printstring text
			jsr krn_primm
			.byte text
			.byte $0a,$00
.endmacro

.macro crlf
	lda #$0a		;\n already does the carriage return
	jsr krn_chrout
.endmacro

memctl = $0230
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
