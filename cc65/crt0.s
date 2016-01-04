;
; ca65 --cpu 6502 crt0.s
; ar65 a ../../cc65/lib/stecki.lib crt0.o
; ---------------------------------------------------------------------------
; crt0.s
; ---------------------------------------------------------------------------
;
; Startup code for cc65 (Single Board Computer version)

.export   _init, _exit
;.import   _main

.export   __STARTUP__ : absolute = 1        ; Mark as startup
.import   __RAM_START__, __RAM_SIZE__       ; Linker generated

.import    copydata, zerobss, initlib, donelib
.import    moveinit, callmain 
;.import         __MAIN_START__, __MAIN_SIZE__   ; Linker generated
.import         __STACKSIZE__                   ; from configure file
.importzp       ST         
.include  "zeropage.inc"

; ---------------------------------------------------------------------------
; Place the startup code in a special segment

.segment  "STARTUP"

; ---------------------------------------------------------------------------
; A little light 6502 housekeeping

_init:    ;LDX     #$FF                 ; Initialize stack pointer to $01FF
 ;         TXS
  ;        CLD                          ; Clear decimal mode

; ---------------------------------------------------------------------------
; Set cc65 argument stack pointer

          LDA     #<(__RAM_START__ + __RAM_SIZE__)
          STA     sp
          LDA     #>(__RAM_START__ + __RAM_SIZE__)
          STA     sp+1

; Set up the stack.
;    lda     #<(__MAIN_START__ + __MAIN_SIZE__ + __STACKSIZE__)
;    ldx     #>(__MAIN_START__ + __MAIN_SIZE__ + __STACKSIZE__)
;    sta     sp
 ;   stx     sp+1            ; Set argument stack ptr
 
 
; ---------------------------------------------------------------------------
; Initialize memory storage
          JSR     zerobss              ; Clear BSS segment
          JSR     copydata             ; Initialize DATA segment
          JSR     initlib              ; Run constructors

; ---------------------------------------------------------------------------
; Call main()
          jsr     callmain 
          ;JSR     _main

; ---------------------------------------------------------------------------
; Back from main (this is also the _exit entry):  force a software break

_exit:    
          JSR     donelib              ; Run destructors
          BRK
          
;
; int open (const char* name, int flags, ...);
; int __fastcall__ close (int fd);
; int __fastcall__ read (int fd, void* buf, unsigned count);
; int __fastcall__ write (int fd, const void* buf, unsigned count);
;
;.export         args, exit, _open, _close, _read, _write
;.export args, exit, _write
;.export _write
;args            := $FFF0
;exit            := $FFF1
;_open           := $FFF2
;_close          := $FFF3
;_read           := $FFF4
;_write          := $ff00 ; chrout vector

