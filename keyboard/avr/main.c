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
                    
unsigned char key = 0b10100001;
unsigned char bit;

int main( void )
{
	// PCMSK |= (1<<PCINT0);	// pin change mask: listen to portb bit 0
	// GIMSK |= (1<<PCIE);	// enable PCINT interrupt 
	
	//keyboardInit( );

	bit=0;
	DDRB = 0xfe;
	PORTB = 0x00;
	
	// sei( );
	
	int clk = 0;	
PORTB = (key & 1)<<PB1;
	while( 1 )
	{
 		// neg. flanke
		if( (PINB & (1 << PB0)) == 0 && clk == 0) 
		{
			clk = 1;

			if (bit < 7)
			{
				key = key>>1;	
				bit++;
			}		
			else
	    	{
		    	bit = 0;
		    	key = 0b10100001;
	    	}
	
		

			PORTB = (key & 1)<<PB1;
	    	_delay_us(10);	
	    	continue;
		}	

		// pos. flanke
		if( (PINB & (1 << PB0)) == 1 && clk == 1) 
		{	
			clk = 0;		
			continue;
	    } 
	}
	return 0;
}


// ISR(PCINT_vect)	 
// {			     
// 	if( (PINB & (1 << PB0)) == 1) 
// 	{
// 		return;
//     } 
    
    

//  	key = key>>1;
// 	PORTB = (key & 1)<<PB1;

  	
//    	bit ++;


//    	if (bit == 8)
//     {
//     	// key = getKey();
//     	key = 0b10100001;;
//     	bit = 0;
//     	PORTB = (key & 1)<<PB1;


//     }
//    	return;
// }