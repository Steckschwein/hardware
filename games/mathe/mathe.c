#include <stdio.h>
#include <stdlib.h>
//#include <conio.h>  

#define limit 20

static int minus(unsigned int a, unsigned int b){
	printf("%d - %d = ", a, b);
	return (a-b);
}

static int plus(unsigned int a, unsigned int b){
	printf("%d + %d = ", a, b);
	return (a+b);
}

void rechne(int (*calc)(unsigned int, unsigned int)){
		unsigned int i;
		unsigned int a;
		unsigned int b;
		unsigned int expected;
		unsigned int input;
		unsigned int points = 0;
		printf("10 Aufgaben...\n");
		for (i=1;i<=10;i++){
			printf("%d. Aufgabe: ", i);
			a = rand() % limit;
			b = rand() % limit;
			expected = calc(a, b);//use func pointer :P
			scanf("%d", &input);
            printf("%d ", input);
			if(expected == input){
				cprintf("\nRichtig.\n");
				points++;
			}
			else
				cprintf("\nFalsch!\n");
		}
		cprintf("Du hast %d von %d Aufgaben richtig gerechnet.\n", points, (i-1));
}

int main (int argc, const char* argv[]){
	unsigned char c;
    do{
        if(c == '-'){
            rechne(&minus);
        } else if(c == '+'){
            rechne(&plus);
        }
    	cprintf("\nAuswahl:\n");
        cprintf("+ addition\n");
        cprintf("- subtraktion\n");
        cprintf("e exit\n");
    }while((c = getc(stdin)) != 'e');
    
    return EXIT_SUCCESS;
}