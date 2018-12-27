;
; ---------------------------------------------------------------------------
; crt0.s
; ---------------------------------------------------------------------------
;
; Startup code for cc65 (Single Board Computer version)

.export   _init, _exit

.export   __STARTUP__ : absolute = 1        ; Mark as startup
.import   __RAM_START__, __RAM_SIZE__       ; Linker generated

.import    copydata, zerobss, initlib, donelib
.import    moveinit, callmain
.import         __MAIN_START__, __MAIN_SIZE__   ; Linker generated
.import         __STACKSIZE__                   ; from configure file
.importzp       ST

		.include  	"zeropage.inc"	;cc65 default zp
		.include	"../kernel/zeropage.inc"	; FIXME kernel vs default zp ?!?
		.include	"../kernel/kernel_jumptable.inc"

; ---------------------------------------------------------------------------
; Place the startup code in a special segment

.segment  "STARTUP"
_init:

; ---------------------------------------------------------------------------
; A little light 6502 housekeeping

; ---------------------------------------------------------------------------
; Set cc65 argument stack pointer
			LDA     #<(__RAM_START__ + __RAM_SIZE__)
          	STA     sp
          	LDA     #>(__RAM_START__ + __RAM_SIZE__)
          	STA     sp+1

; Set up the stack.
;			lda     #<(__MAIN_START__ + __MAIN_SIZE__ + __STACKSIZE__)
;			ldx     #>(__MAIN_START__ + __MAIN_SIZE__ + __STACKSIZE__)
;			sta     sp
;			stx     sp+1            ; Set argument stack ptr

; ---------------------------------------------------------------------------
; Initialize memory storage
			JSR     zerobss              ; Clear BSS segment
			JSR     copydata             ; Initialize DATA segment
			JSR     initlib              ; Run constructors

; ---------------------------------------------------------------------------
; Call main()
			jsr   callmain

; ---------------------------------------------------------------------------
; Back from main (this is also the _exit entry):  force a software break

_exit:
			JSR     donelib				; Run destructors
			jmp     (retvec)				;
