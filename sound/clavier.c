/*************************/
/*                       */
/* AdLib Clavier         */
/*                       */
/* By Indrek Pinsel 1993 */
/*                       */
/*************************/

void soundport(char index, char value){	
    // asm(
		// mov		dx, 0388h
		// mov		al, index
		// out		dx, al

		// mov		cx, 6
	// )
	// loop1:
	// asm(
		// in		al, dx
		// loop	loop1

		// inc		dx

		// mov		al, value
		// out		dx, al

		// mov		cx, 36
		// dec 	dx
	// )
	// loop2:
	// asm(
		// in		al, dx
		// loop	loop2
	// )
}

unsigned char adlibjam(unsigned char c)
{	if(c < 3) return c;
	if(c < 6) return 5 + c;
	return 10 + c;
}

void soundone(unsigned char ch,
	char ar0, char dr0, char sl0, char rr0, char ml0,
	char ks0, char tl0, char ws0, char avek0,
	char ar1, char dr1, char sl1, char rr1, char ml1,
	char ks1, char tl1, char ws1, char avek1, char fb, char c)
{   soundport(0xc0 + ch, (fb << 1) + c);

	ch = adlibjam(ch);

	soundport(0x60 + ch, (ar0 << 4) + dr0);
	soundport(0x80 + ch, (sl0 << 4) + rr0);
	soundport(0x20 + ch, (avek0 << 4) + ml0);
	soundport(0x40 + ch, (ks0 << 6) + tl0);
	soundport(0xE0 + ch, ws0);

	ch += 3;

	soundport(0x60 + ch, (ar1 << 4) + dr1);
	soundport(0x80 + ch, (sl1 << 4) + rr1);
	soundport(0x20 + ch, (avek1 << 4) + ml1);
	soundport(0x40 + ch, (ks1 << 6) + tl1);
	soundport(0xE0 + ch, ws1);
}

void soundall(
	char ar0, char dr0, char sl0, char rr0, char ml0,
	char ks0, char tl0, char ws0, char avek0,
	char ar1, char dr1, char sl1, char rr1, char ml1,
	char ks1, char tl1, char ws1, char avek1, char fb, char c)
{	int i;
    for(i = 0; i < 9; i++)
	{	soundone(i, ar0, dr0, sl0, rr0, ml0, ks0, tl0, ws0, avek0,
				 ar1, dr1, sl1, rr1, ml1, ks1, tl1, ws1, avek1, fb, c);
	}
}

unsigned active = 0;

void play(unsigned octave, unsigned freq)
{	soundport(0xB0 + active, 0);
	soundport(0xA0 + active, freq & 255);
	soundport(0xB0 + active, 0x20 + (octave << 2) + (freq >> 8));
	active = (active + 1) % 9;
}

char txt1[] = "AdLib Clavier by Indrek Pinsel 1993$";
char txt2[] = "\r\nPlay now or press ESC to exit... $";

void main(void)
{   char c;
	unsigned oc = 3;
	// asm{
		// lea		dx, txt1
		// mov		ah, 9
		// int		21h
		// lea		dx, txt2
		// mov		ah, 9
		// int		21h
	// }
	soundall(5, 2, 1, 0, 0, 0, 13, 0, 0, 11, 4, 4, 6, 0, 2, 0, 0, 0, 0, 0);
	do
	{	
        // asm{
			// mov		ah, 8
			// int		21h
			// cmp		al, 'a'
			// jl		cok
			// cmp		al, 'z'
			// jg		cok
			// add		al, 'A' - 'a'
		// }
		cok:
		c = 0;//_AL;
		switch(c)
		{   case 0:
				asm{
					mov		ah, 8
					int		21h
					mov		c, al
				}
				switch(c)
				{	case 'Q':
						if(oc > 1) oc--;
						break;
					case 'I':
						if(oc < 5) oc++;
						break;
					case ';':
						soundall(5, 2, 1, 0, 0, 0, 13, 0, 0, 11, 4, 4, 6, 0, 2, 0, 0, 0, 0, 0);
						break;
					case '<':
						soundall(8, 1, 1, 1, 1, 2, 4, 1, 13, 15, 2, 1, 3, 0, 0, 0, 0, 0, 0, 1);
						break;
					case '=':
						soundall(15, 3, 2, 3, 0, 0, 0, 0, 0, 15, 4, 2, 5, 0, 0, 0, 0, 0, 0, 1);
						break;
					case '>':
						soundall(0, 0, 0, 0, 0, 0, 0, 0, 0, 13, 2, 3, 5, 0, 2, 0, 0, 0, 0, 0);
						break;
					case '>' + 1:
						soundall(15, 4, 6, 3, 1, 1, 0, 3, 0, 15, 3, 3, 5, 0, 2, 0, 1, 0, 0, 0);
						break;
					case '>' + 2:
						soundall(15, 11, 7, 0, 2, 3, 0, 1, 14, 15, 3, 6, 4, 0, 1, 0, 0, 0, 0, 0);
						break;
					case '>' + 3:
						soundall(0, 0, 0, 0, 0, 0, 0, 0, 0, 13, 2, 3, 5, 0, 2, 0, 0, 0, 0, 0);
						break;
					case '>' + 4:
						soundall(0, 0, 0, 0, 0, 0, 0, 0, 0, 13, 2, 3, 5, 0, 2, 0, 0, 0, 0, 0);
						break;
				}
				break;
			case 'Z':
				play(oc - 1, 0x2AE);
				break;
			case 'S':
				play(oc, 0x16B);
				break;
			case 'X':
				play(oc, 0x181);
				break;
			case 'D':
				play(oc, 0x198);
				break;
			case 'C':
				play(oc, 0x1B0);
				break;
			case 'V':
				play(oc, 0x1CA);
				break;
			case 'G':
				play(oc, 0x1E5);
				break;
			case 'B':
				play(oc, 0x202);
				break;
			case 'H':
				play(oc, 0x220);
				break;
			case 'N':
				play(oc, 0x241);
				break;
			case 'J':
				play(oc, 0x263);
				break;
			case 'M':
				play(oc, 0x287);
				break;
			case ',':
				play(oc, 0x2AE);
				break;
			case 'L':
				play(oc + 1, 0x16B);
				break;
			case '.':
				play(oc + 1, 0x181);
				break;
			case ';':
				play(oc + 1, 0x198);
				break;
			case '/':
				play(oc + 1, 0x1B0);
				break;
			case 'Q':
				play(oc, 0x2AE);
				break;
			case '2':
				play(oc + 1, 0x16B);
				break;
			case 'W':
				play(oc + 1, 0x181);
				break;
			case '3':
				play(oc + 1, 0x198);
				break;
			case 'E':
				play(oc + 1, 0x1B0);
				break;
			case 'R':
				play(oc + 1, 0x1CA);
				break;
			case '5':
				play(oc + 1, 0x1E5);
				break;
			case 'T':
				play(oc + 1, 0x202);
				break;
			case '6':
				play(oc + 1, 0x220);
				break;
			case 'Y':
				play(oc + 1, 0x241);
				break;
			case '7':
				play(oc + 1, 0x263);
				break;
			case 'U':
				play(oc + 1, 0x287);
				break;
			case 'I':
				play(oc + 1, 0x2AE);
				break;
			case '9':
				play(oc + 2, 0x16B);
				break;
			case 'O':
				play(oc + 2, 0x181);
				break;
			case '0':
				play(oc + 2, 0x198);
				break;
			case 'P':
				play(oc + 2, 0x1B0);
				break;
			case '[':
				play(oc + 2, 0x1CA);
				break;
			case '=':
				play(oc + 2, 0x1E5);
				break;
			case ']':
				play(oc + 2, 0x202);
				break;
		}
	} while(c != 27);
}
