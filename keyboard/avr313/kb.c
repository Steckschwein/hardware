#include <avr/pgmspace.h>
#include <avr/interrupt.h>
#include <util/delay.h>

#include "kb.h"
#include "scancodes_de.h"



void init_kb(void)
{
	scan_inptr = scan_buffer;					  // Initialize buffer
	scan_outptr = scan_buffer;
	scan_buffcnt = 0;


	kb_inptr =  kb_buffer;					  // Initialize buffer
	kb_outptr = kb_buffer;
	kb_buffcnt = 0;


	MCUCR 	= (1 << ISC01);					  // INT0 interrupt on falling edge
	GIMSK	= (1 << INT0);						  // Enable INT0 interrupt

	PORTC  	= 3;
	DDRC	= (1 << PC0) | (1 << PC1);


	// send_kb(0xff);
	
}

void send_kb(uint8_t data)
{
	uint8_t loop, mask, parity;

	uint8_t tmp = SREG;
	cli();

	PORTD	= ~(1 << CLOCK);
	DDRD	=  (1 << CLOCK) | (1 << DATAPIN);

	_delay_us(100);
	PORTD	= ~(1 << DATAPIN);
	DDRD	= ~(1 << CLOCK);
	
	// loop_until_bit_is_clear(PIND, CLOCK);

	// set startbit (always 0)
	PORTD &= ~(1 << DATAPIN);
	loop_until_bit_is_set(PIND, CLOCK);
	loop_until_bit_is_clear(PIND, CLOCK);
	
	parity = 0;

	// shift data byte out LSB first
    for (loop=0,mask=0x01;loop<8;loop++, mask=mask<<1)   
	{


		if (data & mask) 
		{
			PORTD |= (1 << DATAPIN);
			parity++;
		}
 		else 
		{
			PORTD &= ~(1 << DATAPIN);
		}

		loop_until_bit_is_set(PIND, CLOCK);
		loop_until_bit_is_clear(PIND, CLOCK);
    }

    // set parity bit
    
    if ((++parity & 0x01) == 0)
    {
    	PORTD &= ~(1 << DATAPIN);
    }
    else
    {
    	PORTD |= (1 << DATAPIN);
    }
    loop_until_bit_is_set(PIND, CLOCK);
	loop_until_bit_is_clear(PIND, CLOCK);
    
    // set stopbit (always 1)
	
	PORTD |= (1 << DATAPIN);
    loop_until_bit_is_set(PIND, CLOCK);
	loop_until_bit_is_clear(PIND, CLOCK);
	
    DDRD	= ~(1 << DATAPIN);
	loop_until_bit_is_clear(PIND, CLOCK);
	loop_until_bit_is_clear(PIND, DATAPIN);
    

    SREG = tmp;
}




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
			// Put character into buffer
			// Increment pointer
			*scan_inptr++ = data;
			scan_buffcnt++;

			// Pointer wrapping
			if (scan_inptr >= scan_buffer + SCAN_BUFF_SIZE)
				scan_inptr = scan_buffer;
		}

		
		// put_scanbuff(data);
	}
}


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
					put_kbbuff(pgm_read_byte(&scancodes[i][offs]));
				}
			 

			}								  // Scan code mode
			// else
			// {
			// 	print_hexbyte(sc);			  // Print scan code
			// 	put_kbbuff(' ');
			// 	put_kbbuff(' ');
			// }
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
	// FIXME: do we really need to disable interrupts during buffer access?
	// uint8_t tmp = SREG;
	// cli();

	if (kb_buffcnt < KB_BUFF_SIZE)			  // If buffer not full
	{
		// Put character into buffer
		// Increment pointer
		*kb_inptr++ = c;
		kb_buffcnt++;

		// Pointer wrapping
		if (kb_inptr >= kb_buffer + KB_BUFF_SIZE)
			kb_inptr = kb_buffer;
	}

	// SREG = tmp;
}

// void put_scanbuff(uint8_t c)
// {
// 	// uint8_t tmp = SREG;
// 	// cli();

// 	if (scan_buffcnt < SCAN_BUFF_SIZE)			  // If buffer not full
// 	{
// 		// Put character into buffer
// 		// Increment pointer
// 		*scan_inptr++ = c;
// 		scan_buffcnt++;

// 		// Pointer wrapping
// 		if (scan_inptr >= scan_buffer + SCAN_BUFF_SIZE)
// 			scan_inptr = scan_buffer;
// 	}

// 	// SREG = tmp;
// }


//-------------------------------------------------------------------
// Get a char from the keyboard buffer.
// Routine does not return until a character is ready!
//-------------------------------------------------------------------
/*
int get_kbchar(void)
{
	int byte;


	// Wait for data
	// while(kb_buffcnt == 0);
	if (kb_buffcnt == 0)
	{
		return 0;
	}
	// uint8_t tmp = SREG;
	// cli();


	// Get byte - Increment pointer
	byte = *kb_outptr++;

	// Pointer wrapping
	if (kb_outptr >= kb_buffer + KB_BUFF_SIZE)
		kb_outptr = kb_buffer;

	// Decrement buffer count
	kb_buffcnt--;

	// SREG = tmp;

	return byte;
}
*/
int get_scanchar(void)
{
	uint8_t byte;


	// Wait for data
	// while(kb_buffcnt == 0);
	if (scan_buffcnt == 0)
	{
		return 0;
	}
	// uint8_t tmp = SREG;
	// cli();


	// Get byte - Increment pointer
	byte = *scan_outptr++;

	// Pointer wrapping
	if (scan_outptr >= scan_buffer + SCAN_BUFF_SIZE)
		scan_outptr = scan_buffer;

	// Decrement buffer count
	scan_buffcnt--;

	// SREG = tmp;

	return byte;
}
