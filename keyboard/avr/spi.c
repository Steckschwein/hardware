#include <stdio.h>
#include <stdlib.h>
#include <avr/io.h>
#include "spi.h"

/*
    Initialize USI as slave
*/
void spiInitSlave()
{
	//DO pin is configured for output
	CTRL_PORT |= _BV(DO_PIN);

	// SS as input
	CTRL_PORT &= ~(1 << SS_PIN);

	// pullup on (DI)
	DATA_PORT |= _BV(DI_PIN); 
	
	//Set three wire mode and set
	//clock to External, positive edge.
	// USICR = _BV(USIWM0) | (0 << USICS0) | _BV(USICS1);
	USICR = _BV(USIWM0) | _BV(USICS1);
	
	//Clear overflow flag
	USISR = _BV(USIOIF);
}


unsigned char spiTransfer(unsigned char val)
{
	USIDR = val;	
	//Clear the overflow flag
	USISR = _BV(USIOIF);

	while ((USISR & (1 << USIOIF)) == 0) {}; // Do nothing until USI has data ready
	return USIDR;
}

uint8_t spiSelected()
{
	return !(PINB & (1 << SS_PIN));
}
