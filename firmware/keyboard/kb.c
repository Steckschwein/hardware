#include <avr/pgmspace.h>
#include <avr/interrupt.h>
#include <util/delay.h>

#include "kb.h"
#include "serial.h"
#include "scancodes_de_cp437.h"

// volatile - due to "concurrent" access by isr and main program
volatile uint8_t kbd_bit_n;
volatile uint8_t kbd_bitcnt;
volatile uint8_t kbd_buffer;

uint8_t kbd_id_1;
uint8_t kbd_id_2;

#define KBD_CMD_BUFFER_IX_CMD 5
#define KBD_CMD_BUFFER_IX_CMD_STATUS 4
#define KBD_CMD_BUFFER_IX_VAL 3
#define KBD_CMD_BUFFER_IX_VAL_STATUS 2

volatile uint8_t kbd_cmd_buffer[6] = {0, 0xaa, 0, 0, 0, 0};
uint16_t kbd_cmd_timeout;
volatile uint16_t kbd_status;

inline void kbd_clock_high()
{
    KBD_CLOCK_DDR &= ~(1 << KBD_CLOCK_PIN); //input
    KBD_CLOCK_PORT |= (1 << KBD_CLOCK_PIN);
}

inline void kbd_clock_low()
{
    KBD_CLOCK_DDR |= (1 << KBD_CLOCK_PIN); // output
    KBD_CLOCK_PORT &= ~(1 << KBD_CLOCK_PIN);
}

inline void kbd_data_high()
{
    KBD_DATA_DDR &= ~(1 << KBD_DATA_PIN);
    KBD_DATA_PORT |= (1 << KBD_DATA_PIN);
}
inline void kbd_data_low()
{
    KBD_DATA_DDR |= (1 << KBD_DATA_PIN); // output
    KBD_DATA_PORT &= ~(1 << KBD_DATA_PIN);
}

void wait_status(uint16_t flag)
{
    uint16_t c = KBD_RESET_DELAY_MILLIS;
    while (!(kbd_status & flag) && (c-- > 0))
    { // wait for flag with counter
        decode();
        _delay_ms(2);
    }
}

uint8_t waitScancode()
{

    uint8_t cnt = 200;
    uint8_t sc = 0;

    while ((kbd_status & KBD_SEND) || (cnt-- > 0 && (sc = get_scancode()) == 0))
    {
        _delay_ms(1); // (PS/2 10-16,7Khz 30-50µs delay)
    }
    return sc;
}

void waitIdle()
{
    while (waitScancode())
        ;
}

uint8_t kbd_send_wait(uint8_t data)
{
    kbd_send(data);
    return waitScancode();
}

void kbd_send(uint8_t data)
{
    uint8_t c = 100;
    // still sending? - we must wait until keyboard has send ACK before starting new send(), otherwise the current (command) byte is dropped entirely
    while ((kbd_status & KBD_SEND) && (c-- > 0))
    {
        _delay_ms(5);
    }
    if (c == 0)
    { // send failed, maybe the device did not send any clock pulses
        cli();
        kbd_init();
        sei();
        kbd_reset();
        return;
    }

    // Initiate request-to-send, the actual sending of the data is handled in the ISR.
    kbd_clock_low(); //pull clock
    _delay_us(100);  // and wait
    cli();
    kbd_bit_n = 1;
    kbd_bitcnt = 0;
    kbd_buffer = data;
    kbd_status |= KBD_SEND;
    kbd_data_low();
    kbd_clock_high(); //release clock, device should start now with "send byte" clock pulses
    sei();
}

#define KBD_CMD_LOOP 0xffff

void kbd_cmd_reset()
{
    kbd_status &= ~KBD_HOST_CMD & ~KBD_HOST_CMD_SEND;
}

/*
	0 to 4	Repeat rate (00000b = 30 Hz, ..., 11111b = 2 Hz)
	5 to 6	Delay before keys repeat (00b = 250 ms, 01b = 500 ms, 10b = 750 ms, 11b = 1000 ms)
*/
uint8_t kbd_receive_command(uint8_t code)
{
    uint8_t ret = KBD_RET_ERROR;

    static uint8_t _ix = 0;

    if (kbd_status & KBD_HOST_CMD_SEND) //sending cmd is in progress and not finished yet
        return ret;

    if (!(kbd_status & KBD_HOST_CMD))
    {
        switch (code)
        {
        case KBD_HOST_CMD_KBD_STATUS:
            if (_ix == 0)
            {
                kbd_cmd_buffer[sizeof(kbd_cmd_buffer) - 1] = kbd_status & 0xff; //status low/high byte, we respond inverse
                kbd_cmd_buffer[sizeof(kbd_cmd_buffer) - 2] = kbd_status >> 8;
                kbd_cmd_buffer[sizeof(kbd_cmd_buffer) - 3] = kbd_id_2;
                kbd_cmd_buffer[sizeof(kbd_cmd_buffer) - 4] = kbd_id_1;
            }
        case KBD_HOST_CMD_CMD_STATUS:
            if (_ix == 0)
            {
                _ix = sizeof(kbd_cmd_buffer);
            }
            if (_ix > 0)
            {
                ret = kbd_cmd_buffer[--_ix];
            }
            break;
        case KBD_CMD_ECHO:
        case KBD_CMD_RESET:
        case KBD_CMD_SCAN_ON:
        case KBD_CMD_SCAN_OFF:
            kbd_status |= KBD_HOST_CMD_SEND; // no value, send immediately
        case KBD_CMD_TYPEMATIC:
        case KBD_CMD_LEDS:
            for (uint8_t i = 2; i < sizeof(kbd_cmd_buffer) - 1; i++)
                kbd_cmd_buffer[i] = 0;
            kbd_cmd_timeout = KBD_CMD_LOOP;
            kbd_cmd_buffer[KBD_CMD_BUFFER_IX_CMD] = code;
            kbd_status |= KBD_HOST_CMD; // keyboard command from host received, value expected
            _ix = 0;                    // reset response buffer
            ret = KBD_RET_ACK;
            break;
        default:
            _ix = 0;
            kbd_cmd_reset(); // ...otherwise reset cmd entirely
        }
    }
    else
    {
        kbd_cmd_buffer[KBD_CMD_BUFFER_IX_VAL] = code;
        kbd_cmd_buffer[KBD_CMD_BUFFER_IX_VAL_STATUS] = 0xff; //indicate that there is cmd value available
        kbd_status |= KBD_HOST_CMD_SEND;                     // set command trigger for kbd_process_command()
        ret = KBD_RET_ACK;
    }
    return ret;
}

void kbd_process_command()
{

    if (kbd_status & KBD_HOST_CMD_SEND)
    {
        waitIdle();

        uint8_t cmd = kbd_cmd_buffer[KBD_CMD_BUFFER_IX_CMD];

        kbd_cmd_buffer[KBD_CMD_BUFFER_IX_CMD_STATUS] = kbd_send_wait(cmd);
        if (cmd == KBD_CMD_RESET)
        { //if cmd was reset we do proceed with the reset() sequence
            kbd_reset();
        }
        else
        {
            if (kbd_cmd_buffer[KBD_CMD_BUFFER_IX_VAL_STATUS]) // command with value?
            {
                kbd_cmd_buffer[KBD_CMD_BUFFER_IX_VAL_STATUS] = kbd_send_wait(kbd_cmd_buffer[KBD_CMD_BUFFER_IX_VAL]);
            }
            kbd_cmd_reset();
        }
    }
    else if (kbd_cmd_timeout-- == 0)
    {
        kbd_cmd_reset();
    }
}

void kbd_identify()
{
    waitIdle();
    kbd_send_wait(KBD_CMD_SCAN_OFF);
    if (kbd_send_wait(KBD_CMD_IDENTIFY) == KBD_RET_ACK)
    {
        kbd_id_1 = waitScancode(); //capture id bytes
        kbd_id_2 = waitScancode();
    }
    kbd_send_wait(KBD_CMD_SCAN_ON);
}

void kbd_reset()
{
    wait_status(KBD_BAT_PASSED);
    if (!(kbd_status & KBD_BAT_PASSED))
    {                            //no BAT, try reset
        kbd_send(KBD_CMD_RESET); // send reset, return code is handled in decode()
        wait_status(KBD_BAT_PASSED);
    }
    kbd_status &= ~KBD_NUMLOCK & ~KBD_CAPS & ~KBD_SCROLL & ~KBD_BREAK & ~KBD_LOCKED;
    kbd_update_leds(); // will set all LED's off
    kbd_identify();
    kbd_cmd_reset();
}

void kbd_init()
{
    kbd_clock_high();
    kbd_data_high();

    kbd_bit_n = 1;
    kbd_bitcnt = 0;
    kbd_buffer = 0;
    kbd_status = 0;

    scan_inptr = scan_buffer; // Initialize buffer
    scan_outptr = scan_buffer;
    scan_buffcnt = 0;

#ifdef USE_IRQ
    DDRC &= ~(1 << IRQ); // release IRQ line
#endif
    PORTC = 0;

    _delay_ms(400); //wait stable, keyboard BAT will be send between 500-700ms

#ifdef MOUSE
    mouse_inptr = mouse_buffer; // Initialize buffer
    mouse_outptr = mouse_buffer;
    mouse_buffcnt = 0;
#endif

    kb_inptr = kb_buffer; // Initialize buffer
    kb_outptr = kb_buffer;
    kb_buffcnt = 0;

#ifdef USART
    // USART init to 8 bit data, odd parity, 1 stopbit

    UCSRB = (1 << RXCIE)   // USART RX Complete Interrupt Enable
            | (1 << RXEN); // USART Receiver Enable

    UCSRC = (1 << URSEL)                   // Register select
            | (1 << UMSEL)                 // Select asynchronous mode
            | (1 << UPM0)                  // Select odd parity
            | (1 << UPM1)                  // Select odd parity
            | (1 << UCSZ0)                 // Select number of data bits (8)
            | (1 << UCSZ1) | (1 << UCPOL); // Clock polarity to falling edge
#else
#ifdef MOUSE
    MCUCR = (1 << ISC01)    // INT0 interrupt on falling edge
            | (1 << ISC10); // INT1 interrupt on falling edge

    GICR = (1 << INT0)    // Enable INT0 interrupt
           | (1 << INT1); // Enable INT1 interrupt
#else
    MCUCR |= (1 << ISC01); // INT0 interrupt on falling edge (ps/2 clock line)
    GICR |= (1 << INT0);   // Enable INT0 interrupt
#endif
#endif
}

#define WD_LOOP_CNT 0x1000

void kbd_watchdog()
{

    static uint8_t wtd_cnt_echo = 3;
    static uint16_t wtd_cnt_down = WD_LOOP_CNT;

    if (wtd_cnt_down == 0)
    {
        if (kbd_status & KBD_ECHO_PASSED)
        { //echo received ? (updated during decode())
            kbd_status &= ~KBD_ECHO_PASSED;
            wtd_cnt_echo = 3; //reset echo counter
        }
        else
        {
            if (kbd_status & KBD_BAT_PASSED)
            {
                if (wtd_cnt_echo == 0)
                {                                  //echo counter is zero, but no echo received yet
                    kbd_status &= ~KBD_BAT_PASSED; // reset BAT status
                    wtd_cnt_echo = 3;
                }
                else
                {
                    wtd_cnt_echo--;
                    kbd_send(KBD_CMD_ECHO); //bat passed, just send ECHO
                }
            }
            else
            {
                kbd_send(KBD_CMD_RESET); // try reset
            }
        }
        wtd_cnt_down = WD_LOOP_CNT;
    }
    wtd_cnt_down--;
}

#ifdef USART
ISR(USART_RXC_vect)
{
    if (scan_buffcnt < SCAN_BUFF_SIZE) // If buffer not full
    {
        *scan_inptr++ = UDR; // Put character into buffer, Increment pointer
        scan_buffcnt++;

        // Pointer wrapping
        if (scan_inptr >= scan_buffer + SCAN_BUFF_SIZE)
            scan_inptr = scan_buffer;
    }
}
#endif

#ifndef USART

void kbd_update_leds()
{
    uint8_t val = 0;

    if (kbd_status & KBD_CAPS)
        val |= 0x04;
    if (kbd_status & KBD_NUMLOCK)
        val |= 0x02;
    if (kbd_status & KBD_SCROLL)
        val |= 0x01;

    kbd_send(KBD_CMD_LEDS);
    kbd_send(val);
}

volatile uint16_t kbd_get_status(void)
{
    return kbd_status;
}

ISR(KBD_INT)
{
    if (kbd_status & KBD_SEND)
    {
        // Send data
        if (kbd_bit_n == 9) // Parity bit - 0xed 1110 1101 => 1011 0111
        {
            if (kbd_bitcnt & 0x01)
                KBD_DATA_PORT &= ~(1 << KBD_DATA_PIN);
            else
                KBD_DATA_PORT |= (1 << KBD_DATA_PIN);
        }
        else if (kbd_bit_n == 10) // Stop bit
        {
            KBD_DATA_PORT |= (1 << KBD_DATA_PIN);
        }
        else if (kbd_bit_n == 11) // ACK bit, set by device
        {
            kbd_buffer = 0;
            kbd_bit_n = 0;
            kbd_status &= ~KBD_SEND;
            kbd_data_high();
        }
        else // Data bits
        {
            if (kbd_buffer & (1 << (kbd_bit_n - 1)))
            {
                KBD_DATA_PORT |= (1 << KBD_DATA_PIN);
                kbd_bitcnt++;
            }
            else
            {
                KBD_DATA_PORT &= ~(1 << KBD_DATA_PIN);
            }
        }
    }
    else
    {
        // Receive data
        if (kbd_bit_n > 1 && kbd_bit_n < 10) // Ignore start, parity & stop bit
        {
            if (KBD_DATA_IN & (1 << KBD_DATA_PIN))
                kbd_buffer |= (1 << (kbd_bit_n - 2));
        }
        else if (kbd_bit_n == 11)
        {
            if (scan_buffcnt < SCAN_BUFF_SIZE) // If buffer not full
            {
                *scan_inptr++ = kbd_buffer; // Put character into buffer, Increment pointer
                scan_buffcnt++;
                // Pointer wrapping
                if (scan_inptr == scan_buffer + SCAN_BUFF_SIZE)
                    scan_inptr = scan_buffer;
            }
            kbd_buffer = 0;
            kbd_bit_n = 0;
        }
    }
    kbd_bit_n++;
}

#ifdef MOUSE
ISR(INT1_vect)
{
    static uint8_t data = 0;      // Holds the received scan code
    static uint8_t bitcount = 11; // 0 = neg.  1 = pos.

    if (bitcount < 11 && bitcount > 2) // Bit 3 to 10 is data. Parity bit,
    {                                  // start and stop bits are ignored.
        data = (data >> 1);
        if (PS2_IN & (1 << MOUSE_DATAPIN))
            data = data | 0x80; // Store a '1'
    }

    if (--bitcount == 0) // All bits received
    {
        bitcount = 11;

        if (mouse_buffcnt < SCAN_BUFF_SIZE) // If buffer not full
        {
            *mouse_inptr++ = data; // Put character into buffer, Increment pointer
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
    _delay_us(200);
    DDRC &= ~line;
    return;
}

void decode()
{
    static uint8_t mode = 0;
    uint8_t ch, offs;

    uint8_t sc = get_scancode();

    if (sc == 0)
        return; //0x00 - TODO FIXME maybe the KBD_OVERRUN CODE

    if (sc == KBD_RET_ACK)
    {
        // command acknowledge, ignore
    }
    else if (sc == KBD_RET_RESEND)
    {
        // TODO impl. resend
    }
    else if (sc == KBD_RET_ECHO)
    {
        kbd_status |= KBD_ECHO_PASSED; //required by watchdog
    }
    else if (sc == KBD_RET_BAT_FAIL1 || sc == KBD_RET_BAT_FAIL2)
    {
        kbd_status &= ~KBD_BAT_PASSED; // bat failed, update status, ignore sc
    }
    else if (sc == KBD_RET_BAT_OK)
    {
        kbd_status |= KBD_BAT_PASSED; // bat ok, update status, ignore sc
    }
    else if (!(kbd_status & KBD_BREAK)) // Last data received was the up-key identifier 0xf0
    {
        switch (sc)
        {
        case 0xe0:
            kbd_status |= KBD_EX; // extended code
            break;
        case 0xF0:
            kbd_status |= KBD_BREAK; // break (key release)
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
            if (!(kbd_status & KBD_LOCKED))
            {
                kbd_status |= KBD_LOCKED;
                kbd_status = (kbd_status & KBD_NUMLOCK) ? kbd_status & ~KBD_NUMLOCK : kbd_status | KBD_NUMLOCK;
                kbd_update_leds();
            }
            break;
        case 0x58: // caps lock
            if (!(kbd_status & KBD_LOCKED))
            {
                kbd_status |= KBD_LOCKED;
                kbd_status = (kbd_status & KBD_CAPS) ? kbd_status & ~KBD_CAPS : kbd_status | KBD_CAPS;
                kbd_update_leds();
            }
            break;
        case 0x7e: // scroll lock
            if (!(kbd_status & KBD_LOCKED))
            {
                kbd_status |= KBD_LOCKED;
                kbd_status = (kbd_status & KBD_SCROLL) ? kbd_status & ~KBD_SCROLL : kbd_status | KBD_SCROLL;
                kbd_update_leds();
            }
            break;
        default:
            if (mode == 0 || mode == 3) // If ASCII mode
            {
                if (kbd_status & KBD_CTRL && kbd_status & KBD_ALT && sc == 0x71) // CTRL ALT DEL
                {
                    pull_line((1 << RESET_TRIG));
                    return;
                }

                if (kbd_status & KBD_CAPS) // caps lock
                {
                    if (kbd_status & KBD_SHIFT) // and also shift, than cancel each other
                    {
                        offs = 0;
                    }
                    else
                    {
                        offs = 1;
                    }
                }
                else if (kbd_status & KBD_SHIFT) // shift pressed
                {
                    offs = 1;
                }
                else if (kbd_status & KBD_CTRL)
                {
                    offs = 2;
                }
                else if (kbd_status & KBD_ALT)
                {
                    offs = 3;
                }
                else
                {
                    offs = 0;
                }

                ch = pgm_read_byte(&scancodes[sc][offs]);
                if (ch != 0)
                {
                    if (ch == KBD_RET_ACK)
                    {
                        kbd_status |= KBD_NUMLOCK;
                    }
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
        kbd_status &= ~KBD_BREAK; // Two 0xF0 in a row not allowed
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
        case 0x77: // Caps lock, num lock or scroll lock
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
    if (kb_buffcnt < KB_BUFF_SIZE) // If buffer not full
    {
        *kb_inptr++ = c; // Put character into buffer, Increment pointer
        cli();
        kb_buffcnt++;
        sei();

        // Pointer wrapping
        if (kb_inptr == kb_buffer + KB_BUFF_SIZE)
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
    if (scan_outptr == scan_buffer + SCAN_BUFF_SIZE)
        scan_outptr = scan_buffer;

    cli();
    scan_buffcnt--; // Decrement buffer count
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
