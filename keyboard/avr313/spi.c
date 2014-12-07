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

	/* Set MISO output, all others input */
	DDR_SPI = (1<<DD_MISO);
	/* Enable SPI */
	SPCR = (1<<SPE);

}

unsigned char spiEnabled()
{
	return 	!(PORTB & (1<<PB2));

}

unsigned char spiTransfer(unsigned char val)
{
	while(!(SPSR & (1<<SPIF)));

	SPDR = val;

	/* Wait for reception complete */
	while(!(SPSR & (1<<SPIF)));
	/* Return data register */
	return SPDR;
}
	