#include <avr/pgmspace.h>
#include "keycodes.h"
#include "scancodes.h"

// scan_to_ascii[][scancode, ASCII, Shifted ASCII]
// static const prog_uchar  scan_to_ascii[][5] = 
// {
// {0x01, F9,	SHIFT_F9,	CTL_F9,		ALT_F9},
// {0x03, F5,	SHIFT_F5,	CTL_F5,		ALT_F5},
// {0x04, F3,	SHIFT_F3,	CTL_F3,		ALT_F3},
// {0x05, F1,	SHIFT_F1,	CTL_F1,		ALT_F1},
// {0x06, F2,	SHIFT_F2,	CTL_F2,		ALT_F2},
// {0x07, F12,	SHIFT_F12,	CTL_F12,	ALT_F12},
// {0x09, F10,	SHIFT_F10,	CTL_F10,	ALT_F10},
// {0x0a, F8,	SHIFT_F8,	CTL_F8,		ALT_F8},
// {0x0b, F6,	SHIFT_F6,	CTL_F6,		ALT_F6},
// {0x0c, F4,	SHIFT_F4,	CTL_F4,		ALT_F4},
// {0x0d, TAB,	SHIFT_TAB,	NOT_USED,	NOT_USED},
// {0x0e, '~',	'`',		NOT_USED,	NOT_USED},
// {0x15, 'q',	'Q',		CTL_Q,		NOT_USED},
// {0x16, '1',	'!',		NOT_USED,	NOT_USED},
// {0x1a, 'z',	'Z',		CTL_Z,		NOT_USED},
// {0x1b, 's',	'S',		CTL_S,		NOT_USED},
// {0x1c, 'a',	'A',		CTL_A,		NOT_USED},
// {0x1d, 'w',	'W',		CTL_W,		NOT_USED},
// {0x1e, '2',	'@',		NOT_USED,	NOT_USED},
// {0x1f, WIN,	WIN,		WIN,		WIN},
// {0x21, 'c',	'C',		CTL_C,		NOT_USED},
// {0x22, 'x',	'X',		CTL_X,		NOT_USED},
// {0x23, 'd',	'D',		CTL_D,		NOT_USED},
// {0x24, 'e',	'E',		CTL_E,		NOT_USED},
// {0x25, '4',	'$',		NOT_USED,	NOT_USED},
// {0x26, '3',	'#',		NOT_USED,	NOT_USED},
// {0x29, SPACE,	SPACE,		SPACE,		SPACE},
// {0x2a, 'v',	'V',		CTL_V,		NOT_USED},
// {0x2b, 'f',	'F',		CTL_F,		NOT_USED},
// {0x2c, 't',	'T',		CTL_T,		NOT_USED},
// {0x2d, 'r',	'R',		CTL_R,		NOT_USED},
// {0x2e, '5',	'%',		NOT_USED,	NOT_USED},
// {0x2f, MENU,	MENU,		MENU,		MENU},
// {0x31, 'n',	'N',		CTL_N,		NOT_USED},
// {0x32, 'b',	'B',		CTL_B,		NOT_USED},
// {0x33, 'h',	'H',		CTL_H,		NOT_USED},
// {0x34, 'g',	'G',		CTL_G,		NOT_USED},
// {0x35, 'y',	'Y',		CTL_Y,		NOT_USED},
// {0x36, '6',	'^',		NOT_USED,	NOT_USED},
// {0x3a, 'm',	'M',		CTL_M,		NOT_USED},
// {0x3b, 'j',	'J',		CTL_J,		NOT_USED},
// {0x3c, 'u',	'U',		CTL_U,		NOT_USED},
// {0x3d, '7',	'&',		NOT_USED,	NOT_USED},
// {0x3e, '8',	'*',		NOT_USED,	NOT_USED},
// {0x41, ',',	'<',		NOT_USED,	NOT_USED},
// {0x42, 'k',	'K',		CTL_K,		NOT_USED},
// {0x43, 'i',	'I',		CTL_I,		NOT_USED},
// {0x44, 'o',	'O',		CTL_O,		NOT_USED},
// {0x45, '0',	')',		NOT_USED,	NOT_USED},
// {0x46, '9',	'(',		NOT_USED,	NOT_USED},
// {0x49, '.',	'>',		NOT_USED,	NOT_USED},
// {0x4a, '/',	'?',		NOT_USED,	NOT_USED},
// {0x4b, 'l',	'L',		CTL_L,		NOT_USED},
// {0x4c, ';',	':',		NOT_USED,	NOT_USED},
// {0x4d, 'p',	'P',		CTL_P,		NOT_USED},
// {0x4e, '-',	'_',		NOT_USED,	NOT_USED},
// {0x52, 0x27,	'"',		NOT_USED,	NOT_USED},
// {0x54, '[',	'{',		NOT_USED,	NOT_USED},
// {0x55, '=',	'+',		NOT_USED,	NOT_USED},
// {0x58, C_LOCK,	C_LOCK,		C_LOCK,		C_LOCK},
// {0x5a, 0x0d,	0x0d,		0x0d,		0x0d},
// {0x5b, ']',	'}',		NOT_USED,	NOT_USED},
// {0x5d, '\\',	'|',		NOT_USED,	NOT_USED},
// {0x66, BS,	SHIFT_BS,	CTL_BS,		NOT_USED},
// {0x69, END,	SHIFT_END,	CTL_END,	NOT_USED},
// {0x6b, LEFT,	SHIFT_LEFT,	CTL_LEFT,	NOT_USED},
// {0x6c, HOME,	SHIFT_HOME,	CTL_HOME,	NOT_USED},
// {0x70, INS,	SHIFT_INS,	CTL_INS,	NOT_USED},
// {0x71, DEL,	SHIFT_DEL,	CTL_DEL,	NOT_USED},
// {0x72, DOWN,	SHIFT_DOWN,	CTL_DOWN,	NOT_USED},
// {0x74, RIGHT,	SHIFT_RIGHT,	CTL_RIGHT,	NOT_USED},
// {0x75, UP,	SHIFT_UP,	CTL_UP,		NOT_USED},
// {0x76, ESC,	SHIFT_ESC,	CTL_ESC,	NOT_USED},
// {0x78, F11,	SHIFT_F11,	CTL_F11,	ALT_F11},
// {0x7a, PGDN,	SHIFT_PGDN,	CTL_PGDN,	NOT_USED},
// {0x7d, PGUP,	SHIFT_PGUP,	CTL_PGUP,	NOT_USED},
// {0x83, F7,	SHIFT_F7,	CTL_F7,		ALT_F7}
// };
// unsigned char keyCount = 75; // Count of above keys.


// German Keymap
static const prog_uchar  scan_to_ascii[][5] = 
{
{0x01, F9,	SHIFT_F9,	CTL_F9,		ALT_F9},
{0x03, F5,	SHIFT_F5,	CTL_F5,		ALT_F5},
{0x04, F3,	SHIFT_F3,	CTL_F3,		ALT_F3},
{0x05, F1,	SHIFT_F1,	CTL_F1,		ALT_F1},
{0x06, F2,	SHIFT_F2,	CTL_F2,		ALT_F2},
{0x07, F12,	SHIFT_F12,	CTL_F12,	ALT_F12},
{0x09, F10,	SHIFT_F10,	CTL_F10,	ALT_F10},
{0x0a, F8,	SHIFT_F8,	CTL_F8,		ALT_F8},
{0x0b, F6,	SHIFT_F6,	CTL_F6,		ALT_F6},
{0x0c, F4,	SHIFT_F4,	CTL_F4,		ALT_F4},
{0x0d, TAB,	SHIFT_TAB,	NOT_USED,	NOT_USED},
{0x0e, '^',	'°',		NOT_USED,	NOT_USED},
{0x15, 'q',	'Q',		CTL_Q,		NOT_USED},
{0x16, '1',	'!',		NOT_USED,	NOT_USED},
{0x1a, 'y',	'Y',		CTL_Y,		NOT_USED},
{0x1b, 's',	'S',		CTL_S,		NOT_USED},
{0x1c, 'a',	'A',		CTL_A,		NOT_USED},
{0x1d, 'w',	'W',		CTL_W,		NOT_USED},
{0x1e, '2',	'"',		NOT_USED,	NOT_USED},
{0x1f, WIN,	WIN,		WIN,		WIN},
{0x21, 'c',	'C',		CTL_C,		NOT_USED},
{0x22, 'x',	'X',		CTL_X,		NOT_USED},
{0x23, 'd',	'D',		CTL_D,		NOT_USED},
{0x24, 'e',	'E',		CTL_E,		NOT_USED},
{0x25, '4',	'$',		NOT_USED,	NOT_USED},
{0x26, '3',	'§',		NOT_USED,	NOT_USED},
{0x29, SPACE,	SPACE,		SPACE,		SPACE},
{0x2a, 'v',	'V',		CTL_V,		NOT_USED},
{0x2b, 'f',	'F',		CTL_F,		NOT_USED},
{0x2c, 't',	'T',		CTL_T,		NOT_USED},
{0x2d, 'r',	'R',		CTL_R,		NOT_USED},
{0x2e, '5',	'%',		NOT_USED,	NOT_USED},
{0x2f, MENU,	MENU,		MENU,		MENU},
{0x31, 'n',	'N',		CTL_N,		NOT_USED},
{0x32, 'b',	'B',		CTL_B,		NOT_USED},
{0x33, 'h',	'H',		CTL_H,		NOT_USED},
{0x34, 'g',	'G',		CTL_G,		NOT_USED},
{0x35, 'z',	'Z',		CTL_Z,		NOT_USED},
{0x36, '6',	'&',		NOT_USED,	NOT_USED},
{0x3a, 'm',	'M',		CTL_M,		NOT_USED},
{0x3b, 'j',	'J',		CTL_J,		NOT_USED},
{0x3c, 'u',	'U',		CTL_U,		NOT_USED},
{0x3d, '7',	'/',		NOT_USED,	NOT_USED},
{0x3e, '8',	'(',		NOT_USED,	NOT_USED},
{0x41, ',',	';',		NOT_USED,	NOT_USED},
{0x42, 'k',	'K',		CTL_K,		NOT_USED},
{0x43, 'i',	'I',		CTL_I,		NOT_USED},
{0x44, 'o',	'O',		CTL_O,		NOT_USED},
{0x45, '0',	'=',		NOT_USED,	NOT_USED},
{0x46, '9',	')',		NOT_USED,	NOT_USED},
{0x49, '.',	':',		NOT_USED,	NOT_USED},
{0x4a, '-',	'_',		NOT_USED,	NOT_USED},
{0x4b, 'l',	'L',		CTL_L,		NOT_USED},
{0x4c, 'ö',	'Ö',		NOT_USED,	NOT_USED},
{0x4d, 'p',	'P',		CTL_P,		NOT_USED},
{0x4e, 'ß',	'?',		NOT_USED,	'\\'},

{0x52, 'ä',	'Ä',		NOT_USED,	NOT_USED},
{0x54, 'ü',	'Ü',		NOT_USED,	NOT_USED},
{0x55, '´',	'`',		NOT_USED,	NOT_USED},
{0x58, C_LOCK,	C_LOCK,		C_LOCK,		C_LOCK},
{0x5a, 0x0d,	0x0d,		0x0d,		0x0d},
{0x5b, '+',	'*',		NOT_USED,	'~'},
{0x5d, '#',	'\'',		NOT_USED,	NOT_USED},
{0x61, '<',	'>',		NOT_USED,	'|'},
{0x66, BS,	SHIFT_BS,	CTL_BS,		NOT_USED},
{0x69, END,	SHIFT_END,	CTL_END,	NOT_USED},
{0x6b, LEFT,	SHIFT_LEFT,	CTL_LEFT,	NOT_USED},
{0x6c, HOME,	SHIFT_HOME,	CTL_HOME,	NOT_USED},
{0x70, INS,	SHIFT_INS,	CTL_INS,	NOT_USED},
{0x71, DEL,	SHIFT_DEL,	CTL_DEL,	NOT_USED},
{0x72, DOWN,	SHIFT_DOWN,	CTL_DOWN,	NOT_USED},
{0x74, RIGHT,	SHIFT_RIGHT,	CTL_RIGHT,	NOT_USED},
{0x75, UP,	SHIFT_UP,	CTL_UP,		NOT_USED},
{0x76, ESC,	SHIFT_ESC,	CTL_ESC,	NOT_USED},
{0x78, F11,	SHIFT_F11,	CTL_F11,	ALT_F11},
{0x7a, PGDN,	SHIFT_PGDN,	CTL_PGDN,	NOT_USED},
{0x7d, PGUP,	SHIFT_PGUP,	CTL_PGUP,	NOT_USED},
{0x83, F7,	SHIFT_F7,	CTL_F7,		ALT_F7}
};


unsigned char keyCount = 76; // Count of above keys.

unsigned char decodeScanCode( unsigned char scanCode, unsigned char flags )
{
	unsigned char offset;
	unsigned char result = NOT_USED;
	unsigned char min = 0;
	unsigned char max = keyCount - 1;
	unsigned char mid;
	unsigned char value;

	while ( min <= max )
	{
		mid = ( min + max ) / 2;
		value = pgm_read_byte( &scan_to_ascii[mid][0] );
		if ( value == scanCode )
			break;
		if ( scanCode > value )
			min = mid + 1;
		else
			max = mid - 1;
	}


	if ( min <= max )
	{
		offset = 1;
		if ( flags & (SHIFT_FLAG | CLOCK_FLAG))
		{
			offset = 2;
		}
		else if ( flags & CTL_FLAG )
		{
			offset = 3;
		}
		else if ( flags & ALT_FLAG )
		{
			offset = 4;
		}
		result = pgm_read_byte(&scan_to_ascii[mid][offset]);
	}

	return result;
}
