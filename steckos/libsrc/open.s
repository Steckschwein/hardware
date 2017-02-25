;
;
; int open(const char *name,int flags,...);

		.include "fcntl.inc"
        .include "errno.inc"
		.include	"../kernel/kernel_jumptable.inc"
;		.include	"../kernel/zeropage.inc"

        .export _open
        .destructor     closeallfiles, 5

		.import popax
        .import incsp4
        .import ldaxysp,addysp
        .import __oserror
        .importzp tmp3
		
;--------------------------------------------------------------------------
; _open
.proc   _open
        dey                     ; parm count < 4 shouldn't be needed to be checked
        dey                     ;       (it generates a c compiler warning)
        dey
        dey
        beq     parmok          ; parameter count ok
        jsr     addysp          ; fix stack, throw away unused parameters
		bra		parmok

        lda     #<EMFILE        ; "too many open files"
seterr: jsr     __directerrno
        jsr     incsp4          ; clean up stack
        lda     #$FF
        tax
        rts                     ; return -1 ($ffff)

; Parameters ok. Pop the flags and save them into tmp3

parmok: jsr     popax           ; Get flags
        sta     tmp3

; Get the filename from stack and parse it. Bail out if is not ok

        jsr     popax           ; Get name, ptr low/high in a/x
		jsr		krn_open       	; with a/x ptr to path
		
        ;jsr     fnparse         ; Parse it
        ;tax
        bne     oserror         ; Bail out if problem with name

; Get a free file handle and remember it in tmp2
;        jsr     freefd
;        lda     #EMFILE         ; Load error code
 ;       bcs     seterrno        ; Jump in case of errors
;		stx     tmp2

; Check the flags. We cannot have both, read and write flags set, and we cannot
; open a file for writing without creating it.

        lda     tmp3
        and     #(O_RDWR | O_CREAT)
        cmp     #O_RDONLY       ; Open for reading?
        beq     doread          ; Yes: Branch
        cmp     #(O_WRONLY | O_CREAT)   ; Open for writing?
        beq     dowrite

; Invalid open mode

        lda     #EINVAL

; Error entry. Sets _errno, clears _oserror, returns -1

seterrno:
        jmp     __directerrno

; Error entry: Set oserror and errno using error code in A and return -1
oserror:    
        jmp     __mappederrno

; Read bit is set. Add an 'r' to the name

doread:
;		lda     #'r'
 ;       jsr     fnaddmode       ; Add the mode to the name
  ;      lda     #LFN_READ
        ;TODO FIXME
		bra		common          ; Branch always

; If O_TRUNC is set, scratch the file, but ignore any errors

dowrite:
		lda		#ENOSYS			;TODO FIXME implement write
		bne		oserror
		
        lda     tmp3
        and     #O_TRUNC
        beq     notrunc
;        jsr     scratch

; Complete the the file name. Check for append mode here.

notrunc:
        lda     tmp3            ; Get the mode again
        and     #O_APPEND       ; Append mode?
        bne     append          ; Branch if yes

; Setup the name for create mode
;        lda     #'w'
 ;       jsr     fncomplete      ; Add type and mode to the name
  ;      jmp     appendcreate

; Append bit is set. Add an 'a' to the name

append: 
;		lda     #'a'
;       jsr     fnaddmode       ; Add open mode to file name
appendcreate:
;        lda     #LFN_WRITE

		
; Common read/write code. Flags in A, handle in tmp2
common:
		sta     tmp3	; save cleanead flags
		
; Done. Return the handle in a/x
		txa				; offset into fd_area from krn_open2 to a
        ldx     #0
        stx     __oserror       ; Clear _oserror
        rts
.endproc

;--------------------------------------------------------------------------
; closeallfiles: Close all open files.

.proc   closeallfiles

		jmp		krn_close_all

.endproc