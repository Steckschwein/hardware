#include <avr/io.h>
#include <avr/interrupt.h>
#include <util/delay.h>


#include "spi.h"
#include "kb.h"


/* -------------------------------------------------------------------
Design:
1. 	INT0 für Tastaturabfrage hat IMMER prio
	INT0-ISR stopft scancodes in scancode buffer

2. 	Mainloop 
	- dekodiert Scancodes aus scancode-Buffer 
	- Lookup ASCII Zeichen (decode())
	- Zeichen in Zeichenpuffer
	
3.  SPI-Transport in Interrupt
-------------------------------------------------------------------*/



/* -------------------------------------------------------------------
	Atmel application note AVR313 ported for use with GCC
	by Mike Henning - September 2008

	Changes: 
	- Modified to use the ATMEGA16 instead of the obsolete 90S8515.
	- Changed the scan code table for english keyboards
	- Baud rate can be set under project configuration in Avr Studio.
	- The clr screen routine is not implemented - did not see the
	  point here.
---------------------------------------------------------------------
	A few improvements could be made:

	-Check kb parity bit and implement a timeout for keyboard scan
	-Move the call to decode out of the ISR
	-Add support for sending commands to the keyboard
	-Add support for extended keys

-------------------------------------------------------------------*/


int __attribute__((OS_main noreturn)) main(void)
{
	uint8_t tmp;
	init_kb();
	spiInitSlave();
	sei();


	while(1)
	{		
		tmp = get_scanchar();
		if (tmp != 0)
		{
			decode(tmp);
		}	
		
	}
	// return 0;
}


