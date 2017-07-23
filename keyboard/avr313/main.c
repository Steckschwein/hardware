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

---------------------------------------------------------------------
Changes by Thomas Woinke <thomas@steckschwein.de>
	- support ctrl, alt
	- catch ctrl-alt-del, sysrq
	- scan code table for german layout
	- Moved the call to decode out of the ISR
	- PS/2 communication including parity check using AVR USART
	
-------------------------------------------------------------------*/


int __attribute__((OS_main noreturn)) main(void)
{
	uint8_t tmp;
    
    	cli();

	// Clock line low
	//DDRD |= (uint8_t)(1 << PD2) ;
	//PORTD &= (uint8_t)~(1<< PD2);

	// wait at least 100us
	//_delay_us(101);

	// data line low

	// Set PD0 to output
	//DDRD |= (uint8_t)(1 << PD0);
	// Clear bit
	//PORTD &= (uint8_t)~(1<< PD0);

	// clock line back high
	//PORTD = (uint8_t)(1<< PD2);
	//DDRD &= (uint8_t)~(1 << PD2) ;


	// wait for clock to become low
	//while (PIND & (uint8_t)(1<<PD2)) {};

	// set data line
	//PORTD |= (uint8_t)(1 << PD0);

	// Set PD0 to input
	//DDRD &= (uint8_t)~(1 << PD0);

	// wait for clock to become low
	//while (PIND & (uint8_t)(1<<PD0)) {};

	// wait for clock to become low
	//while (PIND & (uint8_t)(1<<PD2)) {};

	init_kb();
	spiInitSlave();
	sei();
	
	while(1)
	{		

		tmp = get_scanchar();
		if (tmp != 0)
		{
		//	put_kbbuff(tmp);

			decode(tmp);
		}

		tmp = get_mousechar();
		if (tmp != 0)
		{
			put_kbbuff(tmp);
		}
		
	}
}


