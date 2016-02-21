#include <conio.h>
#include <time.h>
#include "../../cc65/spi.h"

void set_clock()
{
	*(unsigned char*) 0x210 = 0x76; // select rtc
	spi_write(0x80);
    spi_write(0x00);
    spi_write(0x30);
    spi_write(0x17);//set clock, also 24h mode
    spi_write(7); //sunday
    spi_write(0x21);
    spi_write(0x2); //
    spi_write(0x16); // 
	*(unsigned char*) 0x210 = 0x7e; // deselect spi
} 
int main (void)
{
    struct tm tm;
    time_t t;
    char   buf[64];
    char c;

//    set_clock();
    
    tm.tm_sec   = 9;
    tm.tm_min   = 34;
    tm.tm_hour  = 21;
    tm.tm_mday  = 12;
    tm.tm_mon   = 10;   /* 0..11, so this is november */
    tm.tm_year  = 102;  /* year - 1900, so this is 2002 */
    tm.tm_wday  = 2;    /* Tuesday */
    tm.tm_isdst = 0;

    /* Convert this broken down time into a time_t and back */
    t = mktime (&tm);
    cprintf ("\n\r");
    cprintf ("Test passes if the following lines are"
            "all identical:\n\r");
    cprintf ("3DD173D1 - Tue Nov 12 21:34:09 2002\n\r");
    cprintf ("%08lX - %s\n\r", t, asctime (&tm));
    cprintf ("%08lX - %s\n\r", t, asctime (gmtime (&t)));
    strftime (buf, sizeof (buf), "%c", &tm);
    cprintf ("%08lX - %s\n\r", t, buf);
    strftime (buf, sizeof (buf), "%a %b %d %H:%M:%S %Y", &tm);
    cprintf ("%08lX - %s\n\r", t, buf);

    while(1){
        t = _systime();
        cprintf ("%08lX - %s\n\r", t, asctime (gmtime (&t)));    
        c = cgetc();
        if(c=='c')
            break;
    }
   
    return 0;
}



