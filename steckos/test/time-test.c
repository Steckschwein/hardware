#include <conio.h>
#include <time.h>
#include "../include/spi.h"
#include "../include/rtc.h"

void set_clock()
{
    spi_select_rtc();
	spi_write(0x80);
    spi_write(0x00);
    spi_write(0x30);
    spi_write(0x17);//set clock, also 24h mode
    spi_write(7); //sunday
    spi_write(0x21);
    spi_write(0x2); //
    spi_write(0x16); // 
    spi_deselect();
} 
int main (void)
{
    struct tm tm;
    struct timespec ts;
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
    cprintf ("\n");
    cprintf ("Test passes if the following lines are all identical:\n");
    cprintf ("3DD173D1 - Tue Nov 12 21:34:09 2002\n");
    cprintf ("%08lX - %s\n", t, asctime (&tm));
    cprintf ("%08lX - %s\n", t, asctime (gmtime (&t)));
    strftime (buf, sizeof (buf), "%c", &tm);
    cprintf ("%08lX - %s\n", t, buf);
    strftime (buf, sizeof (buf), "%a %b %d %H:%M:%S %Y", &tm);
    cprintf ("%08lX - %s\n", t, buf);

    while(1){
        clock_gettime(CLOCK_REALTIME, &ts);
        cprintf ("%8lX - %s\n", ts.tv_sec, asctime (gmtime (&ts.tv_sec)));
        c = cgetc();
        if(c=='c')
            break;
    }
   
    return 0;
}