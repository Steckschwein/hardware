#include <stdlib.h>
#include <string.h>
#include <ctype.h>
#include <conio.h>
#include <ym3812.h>

unsigned char snd01[] = {5, 2, 1, 0, 0, 0, 13, 0, 0, 11, 4, 4, 6, 0, 2, 0, 0, 0, 0, 0};
unsigned char snd02[] = {8, 1, 1, 1, 1, 2, 4, 1, 13, 15, 2, 1, 3, 0, 0, 0, 0, 0, 0, 1};
unsigned char snd03[] = {15, 3, 2, 3, 0, 0, 0, 0, 0, 15, 4, 2, 5, 0, 0, 0, 0, 0, 0, 1};
unsigned char snd04[] = {0, 0, 0, 0, 0, 0, 0, 0, 0, 13, 2, 3, 5, 0, 2, 0, 0, 0, 0, 0};
unsigned char snd05[] = {15, 4, 6, 3, 1, 1, 0, 3, 0, 15, 3, 3, 5, 0, 2, 0, 1, 0, 0, 0};
unsigned char snd06[] = {15, 11, 7, 0, 2, 3, 0, 1, 14, 15, 3, 6, 4, 0, 1, 0, 0, 0, 0, 0};
unsigned char snd07[] = {0, 0, 0, 0, 0, 0, 0, 0, 0, 13, 2, 3, 5, 0, 2, 0, 0, 0, 0, 0};
unsigned char snd08[] = {0, 0, 0, 0, 0, 0, 0, 0, 0, 13, 2, 3, 5, 0, 2, 0, 0, 0, 0, 0};

unsigned char* sounds[] = {snd01, snd02, snd03, snd04, snd05, snd06, snd07, snd08};

unsigned char song_ix = 0;

void soundport(char index, char value)
{
    opl2_write(value, index);
/*
    asm{
		mov		dx, 0388h
		mov		al, index
		out		dx, al

		mov		cx, 6
	}

	loop1:
	asm{
		in		al, dx
		loop	loop1

		inc		dx

		mov		al, value
		out		dx, al

		mov		cx, 36
		dec 	dx
	}
	loop2:
	asm{
		in		al, dx
		loop	loop2
	}
    */
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

void soundall(unsigned char* snd){
    int i;
//    cprintf("%d %d %d %d %d %d %d %d %d %d %d %d %d %d %d %d %d %d %d %d ", snd[0], snd[1], snd[2], snd[3], snd[4], snd[5], snd[6], snd[7], snd[8], snd[9], snd[10], snd[11], snd[12], snd[13], snd[14], snd[15], snd[16], snd[17], snd[18], snd[19]);
    for(i = 0; i < 9; i++)
	{
        soundone(i, snd[0], snd[1], snd[2], snd[3], snd[4], snd[5], snd[6], snd[7], snd[8],
				 snd[9], snd[10], snd[11], snd[12], snd[13], snd[14], snd[15], snd[16], snd[17], snd[18], snd[19]);
	}
}

/*
void soundall(
	char ar0, char dr0, char sl0, char rr0, char ml0,
	char ks0, char tl0, char ws0, char avek0,
	char ar1, char dr1, char sl1, char rr1, char ml1,
	char ks1, char tl1, char ws1, char avek1, char fb, char c)
{
    int i;
    for(i = 0; i < 9; i++)
	{	soundone(i, ar0, dr0, sl0, rr0, ml0, ks0, tl0, ws0, avek0,
				 ar1, dr1, sl1, rr1, ml1, ks1, tl1, ws1, avek1, fb, c);
	}
}
*/

unsigned active = 0;

void play(unsigned octave, unsigned freq)
{	soundport(0xB0 + active, 0);
	soundport(0xA0 + active, freq & 255);
	soundport(0xB0 + active, 0x20 + (octave << 2) + (freq >> 8));
	active = (active + 1) % 9;
}

char txt[] =    "AdLib Clavier by Indrek Pinsel 1993$"
                "\nSteckschwein port on 12/21/2018"
                "\nPlay now or press ESC to exit... $"
                "\nPlay on these keys:"
                "\n\nupper manual:"
//                "\n\n  2 3   5 6 7   9 0   `"
//                "\n Q W E R T Z U I O P \x81 *"
                "\n\nlower manual:"
//                "\n\n  S D   G H J   L \x94"
//                "\n Y X C V B N M , . -"
                "\n\n  d e   f a b   d e"
                "\n C D E F G A B C D E"
                "\n\nCrsUp CrsDown - choose octave"
                "\nShift 1 ... 7 - choose sound";

unsigned char mapping(unsigned char note){
    switch (note){
        case 'c': return 'y';
        case 'd': return 'x';
        case 'e': return 'c';
        case 'f': return 'v';
        case 'g': return 'b';
        case 'A': return 'n';
        case 'B': return 'm';
        case 'C': return ',';
        case 'D': return '.';
        case 'E': return '-';        
    }
    return 0;
}

void _sleep(unsigned char s){
    unsigned long l = 0x2000;
    while(s>0){
        while(l>0){
            --l;
        }
        --s;
    }
}
unsigned char* song =   "ggeggegfdfe"
                        "ggeggegfdfe"
                        "edddfffeeeA"
                        "AgggCgegfdc"
                        ;
                        
unsigned char play_song(){
    if(song_ix == strlen(song)){
        song_ix = 0;
        return 0;
    }
//    cprintf("%d\n", song_ix, sizeof(song));
    return mapping(song[song_ix++]);
}
	                
int main (void)
{   unsigned char c;
	unsigned oc = 3;

    /*
	asm{
		lea		dx, txt1
		mov		ah, 9
		int		21h
		lea		dx, txt2
		mov		ah, 9
		int		21h
	}
    */
    opl2_init();
	soundall(snd01);//5, 2, 1, 0, 0, 0, 13, 0, 0, 11, 4, 4, 6, 0, 2, 0, 0, 0, 0, 0);


    cprintf("%s", txt);

    do
	{
    /*
        asm{
			mov		ah, 8
			int		21h
			cmp		al, 'a'
			jl		cok
			cmp		al, 'z'
			jg		cok
			add		al, 'A' - 'a'
		}
		cok:
		c = _AL;
        */
        c = cgetc();
        if (song_ix>0 || c == 'P'){
//            cprintf("%d %d\n", song_ix, strlen(song));
            c = play_song();
            _sleep(1);
        }else{
            c = toupper(c);
//        cprintf("%c %c %d\n",c, toupper(c), isupper(c));
        }
        
        switch(c)
		{   //case 0:
				/*
                asm{
					mov		ah, 8
					int		21h
					mov		c, al
				}
                */
//                switch(c)
//				{
                    case 0x1f:
						if(oc > 1) oc--;
						break;
					case 0x1e:
						if(oc < 5) oc++;
						break;
					case 0x21:
					case 0x22:
					case 0x24:
					case 0x25:
					case 0x26:
						soundall(sounds[c - 0x21]);
						break;
					case 0x15:
						soundall(sounds[2]);
						break;
					case 0x2f:
						soundall(sounds[7]);
						break;
					/*case ' ':
						soundall(5, 2, 1, 0, 0, 0, 13, 0, 0, 11, 4, 4, 6, 0, 2, 0, 0, 0, 0, 0);
						break;
                    case ' ':
						soundall(8, 1, 1, 1, 1, 2, 4, 1, 13, 15, 2, 1, 3, 0, 0, 0, 0, 0, 0, 1);
						break;
					case '=':
						soundall(15, 3, 2, 3, 0, 0, 0, 0, 0, 15, 4, 2, 5, 0, 0, 0, 0, 0, 0, 1);
						break;
                        /*
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
                        */
				//}
				//break;
			case 'Y':
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
			case 0x94:
				play(oc + 1, 0x198);
				break;
			case '-':
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
			case 'Z':
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
			case 0x81:
				play(oc + 2, 0x1CA);
				break;
			case 0x27:
				play(oc + 2, 0x1E5);
				break;
			case 0x2b:
				play(oc + 2, 0x202);
				break;
		}
	} while(c != 27);

    opl2_init();

    return EXIT_SUCCESS;
}
