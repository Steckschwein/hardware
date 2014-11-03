//---------------------------------------------------------------------------------

// main.c

//---------------------------------------------------------------------------------

#include <avr/interrupt.h>
#include <stdio.h>
#include <stdlib.h>
#include <avr/io.h>
#include <avr/delay.h>
#include "keyboard.h"
#include "keycodes.h"

#define CTRL_PORT   DDRB
#define DATA_PORT   PORTB
#define SS_PIN      PB4
#define CLK_PIN     PB7
#define DI_PIN      PB5
#define DO_PIN      PB6

char cData;
static char res = '5';

/*
    Initialize USI as slave
*/
void init()
{
	//DO pin is configured for output
	CTRL_PORT |= _BV(DO_PIN);
	
	//Set three wire mode and set
	//clock to External, positive edge.
	USICR = _BV(USIWM0) | (0 << USICS0) | _BV(USICS1);
	
	//Clear overflow flag
	USISR = _BV(USIOIF);
}


void putSPI(unsigned char val)
{
	USIDR = val;	
	//Clear the overflow flag
	USISR = _BV(USIOIF);

	while ((USISR & (1 << USIOIF)) == 0) {}; // Do nothing until USI has data ready
	res = USIDR;

//	USIDR = ~res;
}

int main( void )
{
	unsigned char key;

	DDRB &= ~(1 << SS_PIN);
	PORTB |= _BV(PB5); // pullup on (DI)

	init();
	keyboardInit();
	sei();

	res = 0;
	while(1)
	{		
		// SS_PIN must be low for us to do something
		if(PINB & (1 << SS_PIN)) 
		{
    		continue;
  		}


		if (( key = getKey()) != 0 )
		{	
			// spi_transfer(key);	
			putSPI(key);					

			// PORTB = key;
			// _delay_ms(10);
		}
		// PORTB=0;
	}

	return 0;
}