#include <avr/pgmspace.h>
#include <avr/interrupt.h>
#include <util/delay.h>

#include "kb.h"
#include "serial.h"
#include "scancodes_de_cp437.h"


volatile uint8_t	kbd_bit_n = 1;
volatile uint8_t	kbd_bitcnt = 0;
volatile uint8_t	kbd_buffer = 0;
volatile uint8_t	kbd_queue[KBD_BUFSIZE + 1];
volatile uint8_t	kbd_queue_idx = 0;
volatile uint16_t	kbd_status = 0;



inline void kbd_clock_high(){
	KBD_CLOCK_DDR &= ~(1<<KBD_CLOCK_PIN);//input
	KBD_CLOCK_PORT |= (1<<KBD_CLOCK_PIN);
}

inline void kbd_clock_low(){
	KBD_CLOCK_DDR |= (1<<KBD_CLOCK_PIN);// output
	KBD_CLOCK_PORT &= ~(1<<KBD_CLOCK_PIN);
}

inline void kbd_data_high(){
	KBD_DATA_DDR &= ~(1<<KBD_DATA_PIN);
	KBD_DATA_PORT |= (1<<KBD_DATA_PIN);
}
inline void kbd_data_low(){
	KBD_DATA_DDR |= (1<<KBD_DATA_PIN);// output
	KBD_DATA_PORT &= ~(1<<KBD_DATA_PIN);
}


void kbd_init(void)
{	
	kbd_clock_high();
	kbd_data_high();
	
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

	GICR	= (1 << INT0)					  // Enable INT0 interrupt
		    | (1 << INT1);					  // Enable INT1 interrupt
#else
	MCUCR 	|= (1 << ISC01);				  // INT0 interrupt on falling edge
	GICR	|= (1 << INT0);					  // Enable INT0 interrupt
#endif
#endif
	
	PORTC = 0;
	DDRC  = 0;
}
uint8_t waitAck();

void kbd_identify(){
	kbd_send(KBD_CMD_SCAN_OFF);
	if(waitAck()){
		kbd_send(KBD_CMD_IDENTIFY);	
		if(waitAck()){
//			while(get_scancode() == 0) _delay_us(30);
		}
	}
	kbd_send(KBD_CMD_SCAN_ON);
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

void kbd_update_leds()
{
	uint8_t	val = 0;

	if(kbd_status & KBD_CAPS) val |= 0x04;
	if(kbd_status & KBD_NUMLOCK) val |= 0x02;
	if(kbd_status & KBD_SCROLL) val |= 0x01;
	
	kbd_send(KBD_CMD_LEDS);
	kbd_send(val);
}

void kbd_send(uint8_t data)
{
	// still sending? - we must wait until keyboard has send ACK before starting new send(), otherwise the current (command) byte is dropped entirely
	while(kbd_status & KBD_SEND) _delay_ms(5);
	
	// Initiate request-to-send, the actual sending of the data is handled in the ISR.
	kbd_clock_low();//pull clock
	_delay_us(100);// and wait
	kbd_bit_n = 1;
	kbd_bitcnt = 0;
	kbd_buffer = data;
	kbd_status |= KBD_SEND;
	kbd_data_low();
	kbd_clock_high();//release clock, device should start now with "send byte" clock pulses
}

ISR(KBD_INT)
{
	if(kbd_status & KBD_SEND)
	{
		// Send data
		if(kbd_bit_n == 9)				// Parity bit - 0xed 1110 1101 => 1011 0111
		{
			if(kbd_bitcnt & 0x01)	   
				KBD_DATA_PORT &= ~(1<<KBD_DATA_PIN);
			else
				KBD_DATA_PORT |= (1<<KBD_DATA_PIN);
		} else if(kbd_bit_n == 10)		// Stop bit
		{
			KBD_DATA_PORT |= (1<<KBD_DATA_PIN);
		} else if(kbd_bit_n == 11) 	// ACK bit, set by device
		{
			kbd_buffer = 0;
			kbd_bit_n = 0;
			kbd_status &= ~KBD_SEND;
			kbd_data_high();
		} else	// Data bits
		{
			if(kbd_buffer & (1 << (kbd_bit_n - 1)))
			{
				KBD_DATA_PORT |= (1<<KBD_DATA_PIN);
				kbd_bitcnt++;
			} else {			
				KBD_DATA_PORT &= ~(1<<KBD_DATA_PIN);
			}
		}
	} else
	{
		// Receive data
		if(kbd_bit_n > 1 && kbd_bit_n < 10)		// Ignore start, parity & stop bit
		{
			if(KBD_DATA_IN & (1<<KBD_DATA_PIN))
				kbd_buffer |= (1 << (kbd_bit_n - 2));
		} else if(kbd_bit_n == 11)
		{
			if (scan_buffcnt < SCAN_BUFF_SIZE)			  // If buffer not full
			{
				*scan_inptr++ = kbd_buffer;   // Put character into buffer, Increment pointer
				scan_buffcnt++;
#ifdef USE_IRQ
				DDRC |= (1 << IRQ);		// pull IRQ line
#endif
				// Pointer wrapping
				if (scan_inptr >= scan_buffer + SCAN_BUFF_SIZE)
					scan_inptr = scan_buffer;
			}
			kbd_buffer = 0;
			kbd_bit_n = 0;
		}
	}
	kbd_bit_n++;
}

#ifdef MOUSE
ISR (INT1_vect)
{
	static uint8_t data = 0;				  // Holds the received scan code
	static uint8_t bitcount = 11;			  // 0 = neg.  1 = pos.

	if(bitcount < 11 && bitcount > 2)		  // Bit 3 to 10 is data. Parity bit,
	{										  // start and stop bits are ignored.
		data = (data >> 1);
		if(PS2_IN & (1 << MOUSE_DATAPIN))
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

void pull_line(uint8_t line)
{
	DDRC |= line;
	_delay_us(50);
	DDRC &= ~line;
	return;
}


void decode(unsigned char sc)
{
							
	static uint8_t mode=0;
	static uint8_t is_up = 0;
	static uint8_t shift = 0;
	static uint8_t ctrl  = 0;
	static uint8_t alt   = 0;

	uint8_t ch, offs;

	if(sc == KBD_RET_ACK){ 
		// command acknowledge, ignore
	} 
	else if(sc == KBD_RET_BAT_OK)
	{ 
		// bat ok, ignore
		kbd_status |= KBD_BAT_PASSED;
	}
	else if (!is_up)								  // Last data received was the up-key identifier 0xf0
	{
		switch (sc)
		{
			case 0xF0:
				is_up = 1;// break (key release)
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
			case 0x77: // num lock
				if(!(kbd_status & KBD_LOCKED)){
					kbd_status |= KBD_LOCKED;
					kbd_status = (kbd_status & KBD_NUMLOCK) ? kbd_status & ~KBD_NUMLOCK : kbd_status | KBD_NUMLOCK;
					kbd_update_leds();
				}
				break;
			case 0x58: // caps lock
				if(!(kbd_status & KBD_LOCKED)){
					kbd_status |= KBD_LOCKED;
					kbd_status = (kbd_status & KBD_CAPS) ? kbd_status & ~KBD_CAPS : kbd_status | KBD_CAPS;
					kbd_update_leds();
				}
				break;
			case 0x7e: // Scroll lock
				if(!(kbd_status & KBD_LOCKED)){
					kbd_status |= KBD_LOCKED;
					kbd_status = (kbd_status & KBD_SCROLL) ? kbd_status & ~KBD_SCROLL : kbd_status | KBD_SCROLL;
					kbd_update_leds();
				}
				break;
			default:
				if(mode == 0 || mode == 3)		  // If ASCII mode
				{

					if (ctrl && alt && sc == 0x71) // CTRL ALT DEL
					{
						pull_line((1 << RESET_TRIG));
						return;
					}

					if(shift)					  // If shift pressed,
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
#ifdef SERIAL_DEBUG
                        putchar(ch);
#endif
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
			case 0x58:
			case 0x77:	// Caps lock, num lock or scroll lock
			case 0x7e:
				kbd_status &= ~KBD_LOCKED; //
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

uint8_t get_scancode(void)
{
	uint8_t sc = 0;

	// Wait for data
	if (scan_buffcnt == 0)
	{
		return 0;
	}

	// Get scan byte - Increment pointer
	sc = *scan_outptr++;

	// Pointer wrapping
	if (scan_outptr >= scan_buffer + SCAN_BUFF_SIZE)
		scan_outptr = scan_buffer;
	// Decrement buffer count
    cli();
	scan_buffcnt--;
    sei();
	
	return sc;
}

uint8_t waitAck(){
	
	uint8_t c = 8;
	uint8_t sc;
	
	while(c-->0 && (sc = get_scancode()) != KBD_RET_ACK) {
		_delay_us(30);	// (PS/2 10-16,7Khz 30-50µs delay)
	}
	return sc == KBD_RET_ACK;
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
