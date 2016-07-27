#include <avr/pgmspace.h>
#include <avr/interrupt.h>
#include <util/delay.h>

#include "kb.h"
#include "scancodes_de.h"



void init_kb(void)
{
	scan_inptr = scan_buffer;				   // Initialize buffer
	scan_outptr = scan_buffer;
	scan_buffcnt = 0;

	kb_inptr =  kb_buffer;					  // Initialize buffer
	kb_outptr = kb_buffer;
	kb_buffcnt = 0;

#ifdef USART
	// USART init to 8 bit data, odd parity, 1 stopbit
	
	UCSRB = (1 << RXCIE) // USART RX Complete Interrupt Enable
		  | (1 << RXEN); // USART Receiver Enable

	
	UCSRC = (1 << URSEL) // Register select
		  | (1 << UMSEL) // Select asynchronous mode
		  | (1 << UPM0)  // Select odd parity
		  | (1 << UPM1)  // Select odd parity
		  | (1 << UCSZ0) // Select number of data bits (8)
		  | (1 << UCSZ1)  
		  | (1 << UCPOL); // Clock polarity to falling edge 
#endif

#ifndef USART
	MCUCR 	= (1 << ISC01);					  // INT0 interrupt on falling edge
	GIMSK	= (1 << INT0);					  // Enable INT0 interrupt
#endif
	PORTC  	= 3;
	DDRC	= (1 << PC0) | (1 << PC1);
}



#ifdef USART
ISR (USART_RXC_vect)
{
	if (scan_buffcnt < SCAN_BUFF_SIZE)			  // If buffer not full
	{
		*scan_inptr++ = UDR;   // Put character into buffer, Increment pointer
		scan_buffcnt++;

		// Pointer wrapping
		if (scan_inptr >= scan_buffer + SCAN_BUFF_SIZE)
			scan_inptr = scan_buffer;
	}

}
#endif

#ifndef USART
ISR (INT0_vect)
{
	static uint8_t data = 0;				  // Holds the received scan code
	static uint8_t bitcount = 11;			  // 0 = neg.  1 = pos.

	if(bitcount < 11 && bitcount > 2)		  // Bit 3 to 10 is data. Parity bit,
	{										  // start and stop bits are ignored.
		data = (data >> 1);
		if(PIND & (1 << DATAPIN))
			data = data | 0x80;				  // Store a '1'
	}     

	if(--bitcount == 0)						  // All bits received
	{
		bitcount = 11;

		if (scan_buffcnt < SCAN_BUFF_SIZE)			  // If buffer not full
		{
			*scan_inptr++ = data;   // Put character into buffer, Increment pointer
			scan_buffcnt++;

			// Pointer wrapping
			if (scan_inptr >= scan_buffer + SCAN_BUFF_SIZE)
				scan_inptr = scan_buffer;
		}
	}
}
#endif

void decode(uint8_t sc)
{
	static uint8_t is_up = 0, mode = 0;
	static uint8_t shift = 0;
	static uint8_t ctrl  = 0;
	static uint8_t alt   = 0;

	uint8_t i, ch, offs;


	offs = 1;

	if (!is_up)								  // Last data received was the up-key identifier
	{
		if(sc == 0xF0)						  // The up-key identifier
		{
			is_up = 1;
		}

		else if(sc == 0x12 || sc == 0x59)	  // Left SHIFT or Right SHIFT
		{
			shift = 1;
		}

		else if (sc == 0x14)		// Left CTRL or Right CTRL
		{
			ctrl=1;
		}

		else if (sc == 0x11)     // Left ALT or Right ALT
		{
			alt=1;
		}

		else if(sc == 0x05)					  // F1
		{
			if(mode == 0)
				mode = 1;					  // Enter scan code mode
			if(mode == 2)
				mode = 3;					  // Leave scan code mode
		}
//        else if(sc == 0x05)
            
		else
		{
			if(mode == 0 || mode == 3)		  // If ASCII mode
			{
				
				if (ctrl && alt && sc == 0x71) // CTRL ALT DEL
				{
					PORTC &= ~(1 << PC0);
					_delay_ms(50);
					PORTC |= (1 << PC0);

					return;
				}


				offs=1;
				if(shift)					  // If shift not pressed,
				{
					offs=2;
				}
				else if (ctrl)
				{
					offs=3;
				}
				else if (alt)
				{
					offs=4;
				}
				
				// do a table look-up
				for(i = 0; (ch = pgm_read_byte(&scancodes[i][0])) != sc && ch; i++);
				if (ch == sc)
				{
                    ch = pgm_read_byte(&scancodes[i][offs]);
                    // if(ch & 0x80){ //escape sequence?
                    //     put_kbbuff(0x1b);   // put 2 byte to buffer
                    //     ch &= 0b01111111;
                    // }
                    put_kbbuff(ch);
				}
			}								  
			else // Scan code mode
			{
                
			}
		}
	}
	else
	{
		is_up = 0;							  // Two 0xF0 in a row not allowed

		if(sc == 0x12 || sc == 0x59)		  // Left SHIFT or Right SHIFT
		{
			shift = 0;
		}
		else if (sc == 0x14)		// Left CTRL or Right CTRL
		{
			ctrl=0;
		}
		else if (sc == 0x11)     // Left ALT or Right ALT
		{
			alt=0;
		}
		else if(sc == 0x05)					  // F1
		{
			if(mode == 1)
				mode = 2;
			if(mode == 3)
				mode = 0;
		}
		else
		{
			if (sc == 0x84) // SYSRQ
			{
				PORTC &= ~(1 << PC1);
				_delay_ms(50);
				PORTC |= (1 << PC1);

				return;
			}
		}
		// case 0x06 :						// F2
		//   clr();
		//   break;
	}
}


//-------------------------------------------------------------------
// Stuff a decoded byte into the keyboard buffer.
// This routine is currently only called by "decode" which is called 
// from within the ISR so atomic precautions are not needed here.
//-------------------------------------------------------------------
void put_kbbuff(uint8_t c)
{
	if (kb_buffcnt < KB_BUFF_SIZE)			  // If buffer not full
	{
		*kb_inptr++ = c;    // Put character into buffer, Increment pointer
        cli();
		kb_buffcnt++;
        sei();
        
		// Pointer wrapping
		if (kb_inptr >= kb_buffer + KB_BUFF_SIZE)
			kb_inptr = kb_buffer;
	}
}

int get_scanchar(void)
{
	uint8_t byte;

	// Wait for data
	if (scan_buffcnt == 0)
	{
		return 0;
	}

	// Get byte - Increment pointer
	byte = *scan_outptr++;
    
	// Pointer wrapping
	if (scan_outptr >= scan_buffer + SCAN_BUFF_SIZE)
		scan_outptr = scan_buffer;
	// Decrement buffer count
    cli();
	scan_buffcnt--;
    sei();
    
    return byte;
}