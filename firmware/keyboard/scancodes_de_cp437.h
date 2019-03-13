
// Control Characters
#define C_SOH 0x01 // Ctrl-A, Start of heading
#define C_STX 0x02 // Ctrl-B, Start of text
#define C_ETX 0x03 // Ctrl-C, End of text
#define C_EOT 0x04 // Ctrl-D, End of transmission
#define C_ENQ 0x05 // Ctrl-E, Enquiry
#define C_BEL 0x07 // Ctrl-G, Bell
#define C_BS  0x08 // Ctrl-H, Backspace


// control keys
#define CRSR_UP 	 0x1E // RS (Record Separator)
#define CRSR_DOWN 	 0x1F // US (Unit separator)
#define CRSR_RIGHT 	 0x10 // DLE (Data Link Escape)
#define CRSR_LEFT 	 0x11 // DC1 (Device Control 1
#define KEY_HOME 	 0x12 // DC2
#define KEY_END 	 0x13 // DC3
#define KEY_DEL 	 0x14 // DC4
#define KEY_ESC		 0x1b // Escape Key

// function keys
#define FUNC_F1     0xF1
#define FUNC_F2     0xF2
#define FUNC_F3     0xF3
#define FUNC_F4     0xF4
#define FUNC_F5     0xF5
#define FUNC_F6     0xF6
#define FUNC_F7     0xF7
#define FUNC_F8     0xF8
#define FUNC_F9     0xF9
#define FUNC_F10     0xFA
#define FUNC_F11     0xFB
#define FUNC_F12     0xFC


const unsigned char scancodes[][5] PROGMEM = {
	[0x01] = { FUNC_F9,  FUNC_F9, 0, 0} ,// F9

	[0x03] = { FUNC_F5,  FUNC_F5, 0, 0} ,// F5
	[0x04] = { FUNC_F3,  FUNC_F3, 0, 0} ,// F3
	[0x05] = { FUNC_F1,  FUNC_F1, 0, 0} ,// F1
	[0x06] = { FUNC_F2,  FUNC_F2, 0, 0} ,// F2
	[0x07] = { FUNC_F12, FUNC_F12, 0, 0} ,// F12
	[0x09] = { FUNC_F10, FUNC_F10, 0, 0} ,// F10

	[0x0a] = { FUNC_F8,  FUNC_F8, 0, 0} ,// F8
	[0x0b] = { FUNC_F6,  FUNC_F6, 0, 0} ,// F6
	[0x0c] = { FUNC_F4,  FUNC_F4, 0, 0} ,// F4
	[0x0d] = { 	9,	 9,	9, 9} ,
	[0x0e] = { '^', 0xF8, 0, 0}, //°

	[0x15] = { 'q', 'Q', 0, '@'} ,
	[0x16] = { '1', '!', 0, 0} ,

	[0x1a] = { 'y', 'Y', 0, 0} ,
	[0x1b] = { 's', 'S', 0, 0} ,
	[0x1c] = { 'a', 'A', C_SOH, 0},
	[0x1d] = {'w', 'W', 0, 0} ,
	[0x1e] = {'2', '"', 0, 0} ,

	[0x21] = {'c', 'C', C_ETX, 0} ,
	[0x22] = {'x', 'X', 0, 0} ,
	[0x23] = {'d', 'D', C_EOT, 0} ,
	[0x24] = {'e', 'E', C_ENQ , '¤'} ,
	[0x25] = {'4', '$', 0, 0} ,
	[0x26] = {'3', 0x15, 0, 0} , //§

	[0x29] = {' ', ' ', 0, 0} ,
	[0x2a] = {'v', 'V', 0, 0} ,
	[0x2b] = {'f', 'F', 0, 0} ,
	[0x2c] = {'t', 'T', 0, 0} ,
	[0x2d] = {'r', 'R', 0, 0} ,
	[0x2e] = {'5', '%', 0, 0} ,

	[0x31] = {'n', 'N', 0, 0} ,
	[0x32] = {'b', 'B', C_STX, 0} ,
	[0x33] = {'h', 'H', C_BS, 0} ,
	[0x34] = {'g', 'G', C_BEL, 0} ,
	[0x35] = {'z', 'Z', 0, 0} ,
	[0x36] = {'6', '&', 0, 0} ,

	[0x39] = {',', ';', 0, 0} ,
	[0x3a] = {'m', 'M', 0, 0xE6} , //µ
	[0x3b] = {'j', 'J', 0, 0} ,
	[0x3c] = {'u', 'U', 0, 0} ,
	[0x3d] = {'7', '/', 0, '{'} ,
	[0x3e] = {'8', '(', 0, '['} ,

	[0x41] = {',', ';', 0, 0} ,
	[0x42] = {'k', 'K', 0, 0} ,
	[0x43] = {'i', 'I', 0, 0} ,
	[0x44] = {'o', 'O', 0, 0} ,
	[0x45] = {'0', '=', 0, '}'} ,
	[0x46] = {'9', ')', 0, ']'} ,
	[0x49] = {'.', ':', 0, 0} ,
	[0x4a] = {'-', '_', 0, 0} ,
	[0x4b] = {'l', 'L', 0, 0} ,
	[0x4c] = { 0x94, 0x99, 0, 0}, //ö
	[0x4d] = {'p', 'P', 0, 0} ,
	[0x4e] = {0xE1, '?', 0, '\\'} , //ß

	[0x52] = {0x84, 0x8E, 0, 0} , //ä

	[0x54] = {0x81,0x9A, 0, 0} , //ü
	[0x55] = {'\'', '`', 0, 0} ,

	[0x5a] = { 13, 13, 0, 0} ,
	[0x5b] = {'+', '*', 0, '~'} ,
	[0x5d] = {'#', '\'', 0, 0} ,

	[0x61] = {'<', '>', 0, '|'} ,

	[0x66] = {C_BS, C_BS , 0, 0} ,

	[0x69] = {KEY_END, KEY_END, 0, 0} ,

	[0x6b] = {CRSR_LEFT, CRSR_LEFT, 0, 0} ,
	[0x6c] = {KEY_HOME, KEY_HOME, 0, 0} ,

	[0x70] = {'0', '0', 0, 0} ,
	[0x71] = {KEY_DEL, KEY_DEL, 0, 0} ,
	[0x72] = {CRSR_DOWN, CRSR_DOWN, 0, 0} ,
	[0x73] = {'5', '5', 0, 0} ,
	[0x74] = {CRSR_RIGHT, CRSR_RIGHT, 0, 0} ,
	[0x75] = {CRSR_UP, CRSR_UP, 0, 0} ,
	[0x76] = {KEY_ESC, KEY_ESC, 0, 0} ,
	[0x78] = { FUNC_F11, FUNC_F11, 0, 0} ,// F11
	[0x79] = {'+', '+', 0, 0} ,
	[0x7a] = {'3', '3', 0, 0} ,
	[0x7b] = {'-', '-', 0, 0} ,
	[0x7c] = {'*', '*', 0, 0} ,
	[0x7d] = {'9', '9', 0, 0} ,

	[0x83] = { FUNC_F7, FUNC_F7, 0, 0} ,// F7

	//[0xe0] = {0,0,0,0} ,// Delete
};
/*
const unsigned char scancodes_bak[][5] PROGMEM = {
//	{scancode, keycode, shifted, ctrl, alt}
	{0x01, FUNC_F9,  FUNC_F9, 0, 0} ,// F9
	{0x03, FUNC_F5,  FUNC_F5, 0, 0} ,// F5
	{0x04, FUNC_F3,  FUNC_F3, 0, 0} ,// F3
	{0x05, FUNC_F1,  FUNC_F1, 0, 0} ,// F1
	{0x06, FUNC_F2,  FUNC_F2, 0, 0} ,// F2
	{0x07, FUNC_F12, FUNC_F12, 0, 0} ,// F12
	{0x09, FUNC_F10, FUNC_F10, 0, 0} ,// F10
	{0x0a, FUNC_F8,  FUNC_F8, 0, 0} ,// F8
	{0x0b, FUNC_F6,  FUNC_F6, 0, 0} ,// F6
	{0x0c, FUNC_F4,  FUNC_F4, 0, 0} ,// F4
	{0x0d,	9,	 9,	9, 9} ,
	{0x0e,'^', 0xF8, 0, 0}, //°
	{0x15,'q', 'Q', 0, '@'} ,
	{0x16,'1', '!', 0, 0} ,
	{0x1a,'y', 'Y', 0, 0} ,
	{0x1b,'s', 'S', 0, 0} ,
	{0x1c,'a', 'A', C_SOH, 0} ,
	{0x1d,'w', 'W', 0, 0} ,
	{0x1e,'2', '"', 0, 0} ,
	{0x21,'c', 'C', C_ETX, 0} ,
	{0x22,'x', 'X', 0, 0} ,
	{0x23,'d', 'D', C_EOT, 0} ,
	{0x24,'e', 'E', C_ENQ , '¤'} ,
	{0x25,'4', '$', 0, 0} ,
	{0x26,'3', 0x15, 0, 0} , //§
	{0x29,' ', ' ', 0, 0} ,
	{0x2a,'v', 'V', 0, 0} ,
	{0x2b,'f', 'F', 0, 0} ,
	{0x2c,'t', 'T', 0, 0} ,
	{0x2d,'r', 'R', 0, 0} ,
	{0x2e,'5', '%', 0, 0} ,
	{0x31,'n', 'N', 0, 0} ,
	{0x32,'b', 'B', C_STX, 0} ,
	{0x33,'h', 'H', C_BS, 0} ,
	{0x34,'g', 'G', C_BEL, 0} ,
	{0x35,'z', 'Z', 0, 0} ,
	{0x36,'6', '&', 0, 0} ,
	{0x39,',', ';', 0, 0} ,
	{0x3a,'m', 'M', 0, 0xE6} , //µ
	{0x3b,'j', 'J', 0, 0} ,
	{0x3c,'u', 'U', 0, 0} ,
	{0x3d,'7', '/', 0, '{'} ,
	{0x3e,'8', '(', 0, '['} ,
	{0x41,',', ';', 0, 0} ,
	{0x42,'k', 'K', 0, 0} ,
	{0x43,'i', 'I', 0, 0} ,
	{0x44,'o', 'O', 0, 0} ,
	{0x45,'0', '=', 0, '}'} ,
	{0x46,'9', ')', 0, ']'} ,
	{0x49,'.', ':', 0, 0} ,
	{0x4a,'-', '_', 0, 0} ,
	{0x4b,'l', 'L', 0, 0} ,
	{0x4c, 0x94, 0x99, 0, 0}, //ö
	{0x4d,'p', 'P', 0, 0} ,
	{0x4e,0xE1, '?', 0, '\\'} , //ß
	{0x52,0x84, 0x8E, 0, 0} , //ä
	{0x54,0x81,0x9A, 0, 0} , //ü
	{0x55,'\'', '`', 0, 0} ,
	{0x5a, 13, 13, 0, 0} ,
	{0x5b,'+', '*', 0, '~'} ,
	{0x5d,'#', '\'', 0, 0} ,
	{0x61,'<', '>', 0, '|'} ,
	{0x66,C_BS, C_BS , 0, 0} ,
	{0x69,KEY_END, KEY_END, 0, 0} ,
	{0x6b,CRSR_LEFT, CRSR_LEFT, 0, 0} ,
	{0x6c,KEY_HOME, KEY_HOME, 0, 0} ,
	{0x70,'0', '0', 0, 0} ,
	{0x71,KEY_DEL, KEY_DEL, 0, 0} ,
	{0x72,CRSR_DOWN, CRSR_DOWN, 0, 0} ,
	{0x73,'5', '5', 0, 0} ,
	{0x74,CRSR_RIGHT, CRSR_RIGHT, 0, 0} ,
	{0x75,CRSR_UP, CRSR_UP, 0, 0} ,
	{0x76,KEY_ESC, KEY_ESC, 0, 0} ,
	{0x78, FUNC_F11, FUNC_F11, 0, 0} ,// F11
	{0x79,'+', '+', 0, 0} ,
	{0x7a,'3', '3', 0, 0} ,
	{0x7b,'-', '-', 0, 0} ,
	{0x7c,'*', '*', 0, 0} ,
	{0x7d,'9', '9', 0, 0} ,
	{0x83, FUNC_F7, FUNC_F7, 0, 0} ,// F7
//	{0xe0,' ', ' ', 0, 0} ,// Delete
	{0,0, 0, 0, 0}
};
*/
