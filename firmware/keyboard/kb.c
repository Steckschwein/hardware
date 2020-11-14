#include <avr/pgmspace.h>
#include <avr/interrupt.h>
#include <util/delay.h>

#include "kb.h"
#include "serial.h"
#include "scancodes_de_cp437.h"

// volatile - due to "concurrent" access by isr and main program
volatile uint8_t	kbd_bit_n = 1;
volatile uint8_t	kbd_bitcnt = 0;
volatile uint8_t	kbd_buffer = 0;
volatile uint16_t	kbd_status = 0;

uint8_t kbd_statusbuffer[5] = { 0xaa, 0, 0, 0, 0 };

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

void wait_status(uint16_t flag) {
	uint8_t c = 250;
	while(!(kbd_status & flag) && c-- > 0){
		// wait for flag, or max 500ms
		decode(get_scancode());
		_delay_ms(2);
	}
}

void kbd_reset(void) {
	wait_status(KBD_BAT_PASSED);
	if(!(kbd_status & KBD_BAT_PASSED)){//no BAT, try reset
		kbd_send(KBD_CMD_RESET);// send reset, return code is handled in decode()
	}		
	wait_status(KBD_BAT_PASSED);
	
	kbd_update_leds();// will set all LED's off
	kbd_identify();	
}

void kbd_init(void)
{
	kbd_clock_high();
	kbd_data_high();

	kbd_bit_n = 1;
	kbd_bitcnt = 0;
	kbd_buffer = 0;
	kbd_status = 0;

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



void kbd_watchdog(){

	static uint8_t wtd_cnt_echo = 3;
	static uint16_t wtd_cnt_down = 0xffff;
	
	if(wtd_cnt_down == 0){
		if(kbd_status & KBD_ECHO_PASSED){//echo received ? (updated during decode())
			kbd_status &= ~KBD_ECHO_PASSED;
			wtd_cnt_echo = 3;//reset echo counter
		}else{
			if(kbd_status & KBD_BAT_PASSED){
				if(wtd_cnt_echo == 0){//echo counter is zero, but no echo received yet
					kbd_status &= ~KBD_BAT_PASSED; // reset BAT status
					wtd_cnt_echo = 3;
				}else{
					wtd_cnt_echo--;
					kbd_send(KBD_CMD_ECHO);//bat passed, just send ECHO
				}
			}else{
				kbd_send(KBD_CMD_RESET);// try reset
			}
		}
		wtd_cnt_down = 0xffff;
	}
	wtd_cnt_down--;
}

uint8_t waitScancode(){

	uint8_t cnt = 100;
	uint8_t sc = 0;

	while((kbd_status & KBD_SEND) || (cnt-->0 && (sc = get_scancode()) == 0)) {
		_delay_ms(1);	// (PS/2 10-16,7Khz 30-50µs delay)
	}
	return sc;
}

void kbd_identify(){
	kbd_send(KBD_CMD_SCAN_OFF);
	while(get_scancode());//critical, flush scan code buffer immediately to be ready for ack
	
	waitScancode();//wait response
	kbd_send(KBD_CMD_IDENTIFY);
	if(waitScancode() == KBD_RET_ACK){
		kbd_statusbuffer[2] = waitScancode();
		kbd_statusbuffer[1] = waitScancode();
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
		// DDRC |= (1 << IRQ);		// pull IRQ line
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

inline uint16_t kbd_get_status(void){
	return kbd_status;
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
				// DDRC |= (1 << IRQ);		// pull IRQ line
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

uint8_t cmd = 0;
uint8_t cmd_value = 0;
uint8_t cmd_req = 0;
uint8_t cmd_timeout = 0xff;//255 loops

/*
	0 to 4	Repeat rate (00000b = 30 Hz, ..., 11111b = 2 Hz)
	5 to 6	Delay before keys repeat (00b = 250 ms, 01b = 500 ms, 10b = 750 ms, 11b = 1000 ms)
*/
uint8_t kbd_receive_command(uint8_t code){

	static uint8_t cmd_res = 0;

	uint8_t ret = 0xff;

	if(cmd_req)//ignore if cmd in progress, not finished yet
		return ret;

	if(cmd == 0){
		switch (code) {
			case KBD_CMD_STATUS:
				if(cmd_res == 0){
					kbd_statusbuffer[sizeof(kbd_statusbuffer)-1] = kbd_status & 0xff;//status low/high byte, we respond inverse
					kbd_statusbuffer[sizeof(kbd_statusbuffer)-2] = kbd_status>>8;
					cmd_res = sizeof(kbd_statusbuffer);
					ret = KBD_RET_ACK;
				}else {
					ret = kbd_statusbuffer[--cmd_res];
				}
				break;
			case KBD_CMD_SCAN_ON:
			case KBD_CMD_SCAN_OFF:
				cmd_req = 1; // command without value, trigger immediately
			case KBD_CMD_TYPEMATIC:
			case KBD_CMD_LEDS:
				cmd = code; // save command code, we have to capture a value before sending it to keyboard
				ret = KBD_RET_ACK;
				break;
			default:
				cmd_res = 0;// ...otherwise make sure out buffer is reset
		}
	}else{
		cmd_value = code;
		cmd_req = 2; // set command trigger for kbd_process_command
		ret = KBD_RET_ACK;
	}
	return ret;
}

static void kbd_cmd_reset(){
	cmd = 0;
	cmd_value = 0;
	cmd_req = 0;
	cmd_timeout = 0xff;
}

void kbd_process_command(){

	if(cmd_req){
		kbd_send(cmd);
		if(cmd_req > 1){ // command with value, so send the value too
			kbd_send(cmd_value);
		}
		kbd_cmd_reset();
	}else if(cmd != 0 && cmd_timeout-- == 0){
		kbd_cmd_reset();
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
	_delay_us(500);
	DDRC &= ~line;
	return;
}


void decode(uint8_t sc)
{
	static uint8_t mode=0;

	uint8_t ch, offs;

	if(sc == KBD_RET_ACK){
		// command acknowledge, ignore
	}
	else if(sc== KBD_RET_RESEND){
		// TODO maybe resend
	}
	else if(sc== KBD_RET_ECHO){
		kbd_status |= KBD_ECHO_PASSED;//required by watchdog
	}
	else if(sc == KBD_RET_BAT_FAIL1 || sc == KBD_RET_BAT_FAIL2)
	{
		kbd_status &= ~KBD_BAT_PASSED; // bat failed, update status, ignore sc
	}
	else if(sc == KBD_RET_BAT_OK)
	{
		kbd_status |= KBD_BAT_PASSED; // bat ok, update status, ignore sc
	}
	else if (!(kbd_status & KBD_BREAK))								  // Last data received was the up-key identifier 0xf0
	{
		switch (sc)
		{
			case 0xe0:
				kbd_status |= KBD_EX;// extended code
				break;
			case 0xF0:
				kbd_status |= KBD_BREAK;// break (key release)
				break;
			case 0x12:
			case 0x59:
				kbd_status |= KBD_SHIFT;
				break;
			case 0x14:
				kbd_status |= KBD_CTRL;
				break;
			case 0x11:
				kbd_status |= KBD_ALT;
//				kbd_status |= KBD_ALT_GR;
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
					if (kbd_status & KBD_CTRL && kbd_status & KBD_ALT && sc == 0x71) // CTRL ALT DEL
					{
						pull_line((1 << RESET_TRIG));
						return;
					}

					if(kbd_status & KBD_CAPS) // caps lock
					{
						if(kbd_status & KBD_SHIFT)	// and also shift, than cancel each other
						{
							offs=0;
						}
						else
						{
							offs=1;
						}
					}
					else if(kbd_status & KBD_SHIFT) // shift pressed
					{
						offs=1;
					}
					else if (kbd_status & KBD_CTRL)
					{
						offs=2;
					}
					else if (kbd_status & KBD_ALT)
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
				else // Scan code mode TODO ?!? what?
				{

				}
				break;
		}
	}
	else
	{
		kbd_status &= ~KBD_BREAK;							  // Two 0xF0 in a row not allowed
		switch (sc)
		{
			case 0x12:
			case 0x59:
				kbd_status &= ~KBD_SHIFT;
				break;
			case 0x14:
				kbd_status &= ~KBD_CTRL;
				break;
			case 0x11:
				kbd_status &= ~KBD_ALT;
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
		kb_buffcnt++;

		// Pointer wrapping
		if (kb_inptr >= kb_buffer + KB_BUFF_SIZE)
			kb_inptr = kb_buffer;
	}
}

uint8_t get_scancode()
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
	
    cli();
	scan_buffcnt--;// Decrement buffer count
    sei();

	return sc;
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
	mouse_buffcnt--;

    return byte;
}
#endif
