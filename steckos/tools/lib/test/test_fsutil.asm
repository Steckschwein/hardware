.include "asmunit.inc" 	; unit test api
.include "kernel.inc"

.include "fat32.inc"

.import dir_show_entry, pagecnt, entries_per_page, dir_attrib_mask
.import dword2asc
.import char_out
.import print_filesize,print_fat_date,print_fat_time, print_filename

.code
    lda #<direntry
    sta dirptr
    lda #>direntry
    sta dirptr+1

    test "fat_entry_filesize"


    ldy #42

    jsr print_filesize
    assertOut "  246543"
    assertY 42
    assert16 direntry, dirptr

    test "fat_entry_wrtdate"

    jsr print_fat_date
    assertY F32DirEntry::WrtDate
    assertOut "00.0"

    test "fat_entry_wrttime"

    jsr print_fat_time
    assertOut "00:0"


    test "fat_entry_filename"

    jsr print_filename
    assertOut "FOOBAR  BAZ"


	brk

cnt: 	.byte $04
dirs:	.byte $00
files:	.byte $00
direntry:
    .byte "FOOBAR  BAZ" ; filename+ext
    .byte 0             ; attribute
    .byte 0             ; Reserved
    .byte 0             ; CrtTimeMillis
    .word $0000         ; CrtTimeMillis
    .word $0000         ; CrtDate
    .word $0000         ; LstModDate
    .word $0000         ; FstClusHI
    .word $0000         ; WrtTime
    .word $0000         ; WrtDate
    .word $0000         ; FstClusLO
    .dword 246543       ; $03c30f

.segment "ASMUNIT"
