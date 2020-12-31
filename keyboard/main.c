#include <avr/interrupt.h>
#include <avr/io.h>
#include <avr/interrupt.h>
#include <util/delay.h>

#include "spi.h"
#include "kb.h"
#include "serial.h"


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

---------------------------------------------------------------------
Changes by Thomas Woinke <thomas@steckschwein.de>
	- support ctrl, alt
	- catch ctrl-alt-del, sysrq
	- scan code table for german layout
	- Moved the call to decode out of the ISR
	- PS/2 communication including parity check using AVR USART

-------------------------------------------------------------------*/


int main(void)
{
	cli();
   
	kbd_init(); //init avr for ps/2

	spiInitSlave();
#ifdef SERIAL_DEBUG
	init_uart();
#endif

	sei();

    kbd_reset();//keyboard reset sequence
	
#ifdef USE_IRQ
	DDRC &= ~(1 << IRQ); // release IRQ line
#endif
    
	while(1)
	{
        decode();

#ifdef USE_IRQ
		if (kb_buffcnt > 0)
		{
			DDRC |= (1 << IRQ);	// pull IRQ line
		}
		else
		{
			DDRC &= ~(1 << IRQ); // release IRQ line
		}
#endif

		kbd_process_command();

		kbd_watchdog();

#ifdef MOUSE
        //TODO FIXME
        put_kbbuff(get_mousechar());
#endif
	}
}
