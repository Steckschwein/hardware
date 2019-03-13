#include <avr/pgmspace.h>
#include <avr/interrupt.h>
#include <util/delay.h>

#include "kb.h"
#include "serial.h"
#include "scancodes_de_cp437.h"




void __attribute__((naked)) pull_line(uint8_t line)
{
	DDRC |= line;
	// PORTC &= ~line;
	_delay_us(50);
	// PORTC |= line;
	DDRC &= ~line;
	return;
}

void init_kb(void)
{
	scan_inptr = scan_buffer;				   // Initialize buffer
	scan_outptr = scan_buffer;
	scan_buffcnt = 0;

#ifdef MOUSE
	mouse_inptr = mouse_buffer;				   // Initialize buffer
	mouse_outptr = mouse_buffer;
	mouse_buffcnt = 0;
#endif


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
#else
#ifdef MOUSE
	MCUCR 	= (1 << ISC01)					  // INT0 interrupt on falling edge
		| (1 << ISC10);					  // INT1 interrupt on falling edge

	GIMSK	= (1 << INT0)					  // Enable INT0 interrupt
		| (1 << INT1);					  // Enable INT1 interrupt
#else
	MCUCR 	= (1 << ISC01);					  // INT0 interrupt on falling edge

	GIMSK	= (1 << INT0);					  // Enable INT0 interrupt
#endif
#endif

	// PORTC  	= 3;
	// DDRC	= (1 << PC0) | (1 << PC1);

	// PORTC	= (1 << PC0) | (1 << PC1) | (1 << PC2);
	// DDRC	= (1 << PC0) | (1 << PC1) | (1 << PC2);

	// PORTC all input, all low
	PORTC = 0;
	DDRC  = 0;
}



#ifdef USART
ISR (USART_RXC_vect)
{
	if (scan_buffcnt < SCAN_BUFF_SIZE)			  // If buffer not full
	{
		*scan_inptr++ = UDR;   // Put character into buffer, Increment pointer
		scan_buffcnt++;

#ifdef USE_IRQ
		DDRC |= (1 << IRQ);		// pull IRQ line
#endif
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
#ifdef USE_IRQ
		DDRC |= (1 << IRQ);		// pull IRQ line
#endif

			// Pointer wrapping
			if (scan_inptr >= scan_buffer + SCAN_BUFF_SIZE)
				scan_inptr = scan_buffer;
		}
	}
}

#ifdef MOUSE
ISR (INT1_vect)
{
	static uint8_t data = 0;				  // Holds the received scan code
	static uint8_t bitcount = 11;			  // 0 = neg.  1 = pos.

	if(bitcount < 11 && bitcount > 2)		  // Bit 3 to 10 is data. Parity bit,
	{										  // start and stop bits are ignored.
		data = (data >> 1);
		if(PIND & (1 << MOUSE_DATAPIN))
			data = data | 0x80;				  // Store a '1'
	}

	if(--bitcount == 0)						  // All bits received
	{
		bitcount = 11;

		if (mouse_buffcnt < SCAN_BUFF_SIZE)			  // If buffer not full
		{
			*mouse_inptr++ = data;   // Put character into buffer, Increment pointer
			mouse_buffcnt++;


			// Pointer wrapping
			if (mouse_inptr >= mouse_buffer + SCAN_BUFF_SIZE)
				mouse_inptr = mouse_buffer;
		}
	}
}
#endif
#endif

void decode(uint8_t sc)
{
	static uint8_t is_up = 0, mode = 0;
	static uint8_t shift = 0;
	static uint8_t ctrl  = 0;
	static uint8_t alt   = 0;

	uint8_t ch, offs;



	// put_kbbuff(sc);
	// return;

	if (!is_up)								  // Last data received was the up-key identifier
	{
		switch (sc)
		{
			case 0xF0:
				is_up = 1;
				break;
			case 0x12:
			case 0x59:
				shift = 1;
				break;
			case 0x14:
				ctrl = 1;
				break;
			case 0x11:
				alt = 1;
				break;
			case 0xAA:
				break;
			default:
				if(mode == 0 || mode == 3)		  // If ASCII mode
				{

					if (ctrl && alt && sc == 0x71) // CTRL ALT DEL
					{
						pull_line((1 << RESET_TRIG));
						return;
					}


					if(shift)					  // If shift not pressed,
					{
						offs=1;
					}
					else if (ctrl)
					{
						offs=2;
					}
					else if (alt)
					{
						offs=3;
					}
					else
					{
						offs=0;
					}

                    ch = pgm_read_byte(&scancodes[sc][offs]);
                    if (ch != 0)
                    {
                        put_kbbuff(ch);
                        putchar(ch);
                    }
				}
				else // Scan code mode
				{

				}
				break;
		}
	}
	else
	{
		is_up = 0;							  // Two 0xF0 in a row not allowed

		switch (sc)
		{
			case 0x12:
			case 0x59:
				shift = 0;
				break;
			case 0x14:
				ctrl = 0;
				break;
			case 0x11:
				alt = 0;
				break;
			case 0xAA:
				break;

			case 0x84: // SYSRQ
				pull_line((1 << NMI));
				return;
		}
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
#ifdef MOUSE
int get_mousechar(void)
{
	uint8_t byte;

	// Wait for data
	if (mouse_buffcnt == 0)
	{
		return 0;
	}

	// Get byte - Increment pointer
	byte = *mouse_outptr++;

	// Pointer wrapping
	if (mouse_outptr >= mouse_buffer + SCAN_BUFF_SIZE)
		mouse_outptr = mouse_buffer;
	// Decrement buffer count
    cli();
	mouse_buffcnt--;
    sei();

    return byte;
}
#endif
