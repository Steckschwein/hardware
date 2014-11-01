//---------------------------------------------------------------------------------

// main.c

//---------------------------------------------------------------------------------

#include <avr/interrupt.h>
#include <stdio.h>
#include <stdlib.h>
#include <avr/io.h>
// #include <avr/delay.h>

#include "keyboard.h"
#include "keycodes.h"

unsigned char key = 0b10001001;
unsigned char bit;




/* USI port and pin definitions.
 */
#define USI_OUT_REG	PORTB	//!< USI port output register.
#define USI_IN_REG	PINB	//!< USI port input register.
#define USI_DIR_REG	DDRB	//!< USI port direction register.
#define USI_CLOCK_PIN	PB7	//!< USI clock I/O pin.
#define USI_DATAIN_PIN	PB5	//!< USI data input pin.
#define USI_DATAOUT_PIN	PB6	//!< USI data output pin.



/*! \brief  Data input register buffer.
 *
 *  Incoming bytes are stored in this byte until the next transfer is complete.
 *  This byte can be used the same way as the SPI data register in the native
 *  SPI module, which means that the byte must be read before the next transfer
 *  completes and overwrites the current value.
 */
unsigned char storedUSIDR;



/*! \brief  Driver status bit structure.
 *
 *  This struct contains status flags for the driver.
 *  The flags have the same meaning as the corresponding status flags
 *  for the native SPI module. The flags should not be changed by the user.
 *  The driver takes care of updating the flags when required.
 */
struct usidriverStatus_t {
	unsigned char masterMode : 1;       //!< True if in master mode.
	unsigned char transferComplete : 1; //!< True when transfer completed.
	unsigned char writeCollision : 1;   //!< True if put attempted during transfer.
};

volatile struct usidriverStatus_t spiX_status; //!< The driver status bits.



/*! \brief  USI Timer Overflow Interrupt handler.
 *
 *  This handler disables the compare match interrupt if in master mode.
 *  When the USI counter overflows, a byte has been transferred, and we
 *  have to stop the timer tick.
 *  For all modes the USIDR contents are stored and flags are updated.
 */
ISR(USI_OVERFLOW_vect) 
{
	// Update flags and clear USI counter
	USISR = (1<<USIOIF);
	spiX_status.transferComplete = 1;

	// Copy USIDR to buffer to prevent overwrite on next transfer.
	storedUSIDR = USIDR;
}






/*! \brief  Initialize USI as SPI slave.
 *
 *  This function sets up all pin directions and module configurations.
 *  Use this function initially or when changing from master to slave mode.
 *  Note that the stored USIDR value is cleared.
 *
 *  \param spi_mode  Required SPI mode, must be 0 or 1.
 */
void spiX_initslave( char spi_mode )
{
	// Configure port directions.
	USI_DIR_REG |= (1<<USI_DATAOUT_PIN);                      // Outputs.
	USI_DIR_REG &= ~(1<<USI_DATAIN_PIN) | (1<<USI_CLOCK_PIN); // Inputs.
	USI_OUT_REG |= (1<<USI_DATAIN_PIN) | (1<<USI_CLOCK_PIN);  // Pull-ups.
	
	// Configure USI to 3-wire slave mode with overflow interrupt.
	USICR = (1<<USIOIE) | (1<<USIWM0) |
	        (1<<USICS1) | (spi_mode<<USICS0);
	
	// Init driver status register.
	spiX_status.masterMode       = 0;
	spiX_status.transferComplete = 0;
	spiX_status.writeCollision   = 0;
	
	storedUSIDR = 0;
}



/*! \brief  Put one byte on bus.
 *
 *  Use this function like you would write to the SPDR register in the native SPI module.
 *  Calling this function in master mode starts a transfer, while in slave mode, a
 *  byte will be prepared for the next transfer initiated by the master device.
 *  If a transfer is in progress, this function will set the write collision flag
 *  and return without altering the data registers.
 *
 *  \returns  0 if a write collision occurred, 1 otherwise.
 */
char spiX_put( unsigned char val )
{
	// Check if transmission in progress,
	// i.e. USI counter unequal to zero.
	if( (USISR & 0x0F) != 0 ) {
		// Indicate write collision and return.
		spiX_status.writeCollision = 1;
		return 0;
	}
	
	// Reinit flags.
	spiX_status.transferComplete = 0;
	spiX_status.writeCollision = 0;

	// Put data in USI data register.
	USIDR = val;
	

	if( spiX_status.writeCollision == 0 ) return 1;
	return 0;
}



/*! \brief  Get one byte from bus.
 *
 *  This function only returns the previous stored USIDR value.
 *  The transfer complete flag is not checked. Use this function
 *  like you would read from the SPDR register in the native SPI module.
 */
unsigned char spiX_get()
{
	return storedUSIDR;
}



/*! \brief  Wait for transfer to complete.
 *
 *  This function waits until the transfer complete flag is set.
 *  Use this function like you would wait for the native SPI interrupt flag.
 */
void spiX_wait()
{
	do {} while( spiX_status.transferComplete == 0 );
}


int main( void )
{
	
	spiX_initslave(0);
	sei();

	while(1)
	{
		spiX_put(key);
		spiX_wait();		// wait for transmission to finish


	}

	return 0;
}


