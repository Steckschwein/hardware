
// MIT License
//
// Copyright (c) 2018 Thomas Woinke, Marko Lauke, www.steckschwein.de
//
// Permission is hereby granted, free of charge, to any person obtaining a copy
// of this software and associated documentation files (the "Software"), to deal
// in the Software without restriction, including without limitation the rights
// to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
// copies of the Software, and to permit persons to whom the Software is
// furnished to do so, subject to the following conditions:
//
// The above copyright notice and this permission notice shall be included in all
// copies or substantial portions of the Software.
//
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
// SOFTWARE.

/*
** Calculate all primes up to a specific number.
*/



#include <stdlib.h>
#include <stdio.h>
#include <ctype.h>
#include <time.h>
#include <conio.h>


/* Workaround missing clock stuff */
//#ifdef __APPLE2__
#  define clock()               0
#  define CLOCKS_PER_SEC        1
//#endif



/*****************************************************************************/
/*                                   Data                                    */
/*****************************************************************************/



#define COUNT           16384           /* Up to what number? */
#define SQRT_COUNT      128             /* Sqrt of COUNT */

static unsigned char Sieve[COUNT];



/*****************************************************************************/
/*                                   Code                                    */
/*****************************************************************************/



#pragma static-locals(1);



static char ReadUpperKey (void)
/* Read a key from console, convert to upper case and return */
{
    return toupper (cgetc ());
}



int main (void)
{
    /* Clock variable */
    clock_t Ticks;
    unsigned Sec;
    unsigned Milli;

    /* This is an example where register variables make sense */
    register unsigned char* S;
    register unsigned       I;
    register unsigned       J;

    /* Output a header */
    cprintf ("Sieve benchmark - calculating primes\n");
    cprintf ("between 2 and %u\n", COUNT);
    cprintf ("Please wait patiently ...\n");

    /* Read the clock */
    Ticks = clock();

    /* Execute the sieve */
    I = 2;
    while (I < SQRT_COUNT) {
        if (Sieve[I] == 0) {
            /* Prime number - mark multiples */
            J = I*2;
            S = &Sieve[J];
            while (J < COUNT) {
                *S = 1;
                S += I;
                J += I;
            }
        }
        ++I;
    }

    /* Calculate the time used */
    Ticks = clock() - Ticks;
    Sec = (unsigned) (Ticks / CLOCKS_PER_SEC);
    Milli = ((Ticks % CLOCKS_PER_SEC) * 1000) / CLOCKS_PER_SEC;

    /* Print the time used */
    cprintf ("Time used: %u.%03u seconds\n", Sec, Milli);
    cprintf ("Q to quit, any other key for list\n");

    /* Wait for a key and print the list if not 'Q' */
    if (ReadUpperKey () != 'Q') {
        /* Print the result */
        J = 0;
        for (I = 2; I < COUNT; ++I) {
            if (Sieve[I] == 0) {
                cprintf ("%4d\n", I);
                if (++J == 23) {
                    cprintf ("Q to quit, any other key continues\n");
                    if (ReadUpperKey () == 'Q') {
                        break;
                    }
                    J = 0;
                }
            }
            if (kbhit() && ReadUpperKey () == 'Q') {
                break;
            }
        }
    }

    return EXIT_SUCCESS;
}
