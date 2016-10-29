#include <stdio.h>
#include <stdlib.h>
#include <conio.h>  

#define limit 20

static int minus(unsigned int a, unsigned int b){
	cprintf("%d - %d = ", a, b);
	return (a-b);
}

static int plus(unsigned int a, unsigned int b){
	cprintf("%d + %d = ", a, b);
	return (a+b);
}

void rechne(int (*calc)(unsigned int, unsigned int)){
		unsigned int i;
		unsigned int a;
		unsigned int b;
		unsigned int expected;
		unsigned int input;
		unsigned int points = 0;
		cprintf("10 Aufgaben...\n");
		for (i=1;i<=10;i++){
			cprintf("%d. Aufgabe: ", i);
			a = rand() % limit;
			b = rand() % limit;
			expected = calc(a, b);//use func pointer :P
			cscanf("%d", &input);
            cprintf("%d ", input);
			if(expected == input){
				cprintf("Richtig.\r\n");
				points++;
			}
			else
				cprintf("Falsch!\r\n");
		}
		cprintf("Du hast %d von %d Aufgaben richtig gerechnet.\r\n", points, (i-1));
}

int main (int argc, const char* argv[]){
	unsigned char c;
    do{
        if(c == '-'){
            rechne(&minus);
        } else if(c == '+'){
            rechne(&plus);
        }
    	cprintf("\n\rAuswahl:\n\r");
        cprintf("+ addition\n\r");
        cprintf("- subtraktion\n\r");
        cprintf("e exit\n\r");
    }while((c = cgetc()) != 'e');
    
    return EXIT_SUCCESS;
}