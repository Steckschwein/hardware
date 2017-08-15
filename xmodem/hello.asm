!src "../steckos/kernel/kernel_jumptable.inc"

* = $3000

	jsr krn_primm	
	!text "Hello World!",13,10,0
loop:	jmp loop


