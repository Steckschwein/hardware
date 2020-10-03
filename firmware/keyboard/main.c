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
	uint8_t c;
	
	cli();
	
	spiInitSlave();
#ifdef SERIAL_DEBUG
	init_uart();
#endif

	_delay_ms(500);// wait keyboard reset
	
	kbd_init();
		
	sei();

	kbd_send(KBD_CMD_RESET);// send reset, return cide is handled in decode()
	_delay_ms(500);
	kbd_update_leds();// will set all LED's off
	kbd_identify();
	
	while(1)
	{		
		c = get_scancode();
		if (c != 0)
		{
			decode(c);
		}
		
		kbd_process_command();
		
#ifdef MOUSE
		c = get_mousechar();
		if (c != 0)
		{
			put_kbbuff(c);
		}
#endif
	}
}
