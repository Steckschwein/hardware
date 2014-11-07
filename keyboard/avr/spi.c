#include <stdio.h>
#include <stdlib.h>
#include <avr/io.h>
#include <avr/interrupt.h>
#include "spi.h"



/*
    Initialize USI as slave
*/
void spiInitSlave()
{
	//DO pin is configured for output
	CTRL_PORT |= _BV(DO_PIN);

	CTRL_PORT |= _BV(PB0) | _BV(PB1);

	// SS as input
	CTRL_PORT &= ~(1 << SS_PIN);

	// Enable pin change interrupt for SS_PIN
	PCMSK |= (1<<PCINT4	);	
	GIMSK |= (1<<PCIE);	

	// pullup on (DI)
	DATA_PORT |= _BV(DI_PIN); 
	
	// RESET
	DATA_PORT |= _BV(PB0); 

	// NMI
	DATA_PORT |= _BV(PB1); 

	//Clear overflow flag
	USISR = _BV(USIOIF);

	//Set three wire mode and set
	//clock to External, positive edge.
	// USICR = _BV(USIWM0) | (0 << USICS0) | _BV(USICS1);
	USICR = (1<<USIOIE) | _BV(USIWM0) | _BV(USICS1);
	


	transferComplete 	= 0;
	// slaveSelect			= 1;
}


// unsigned char spiTransfer(unsigned char val)
// {
// 	USIDR = val;	
// 	//Clear the overflow flag
// 	USISR = _BV(USIOIF);

// 	while ((USISR & (1 << USIOIF)) == 0) {}; // Do nothing until USI has data ready
// 	return USIDR;
// }

unsigned char spiTransfer(unsigned char val)
{
	transferComplete = 0;

	USIDR = val;	
	

	//while ((USISR & (1 << USIOIF)) == 0) {}; // Do nothing until USI has data ready
	while(transferComplete == 0) {}

	return USIDR;
}
	

ISR(USI_OVERFLOW_vect)
{
	//Clear the overflow flag
	USISR = _BV(USIOIF);
	transferComplete = 1;
}


ISR(PCINT_vect)	 
{			     
	// slaveSelect = 	(PINB & (1 << SS_PIN));
	// slaveSelect is 1, we are inactive
	if (PINB & (1 << SS_PIN))
	{
		// slaveSelect = 1;
		// tri state DO pin
		CTRL_PORT &= ~_BV(DO_PIN);
		DATA_PORT &= ~_BV(DO_PIN);
		
		// disable USI
		USICR &= ~_BV(USIWM0);		
		
	}
	else
	{
		// DO pin as output
		CTRL_PORT |= _BV(DO_PIN);

		// enable USI
		USICR |= _BV(USIWM0);			
		// slaveSelect = 0;
	}

}