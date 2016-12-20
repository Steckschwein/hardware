#include <stdlib.h>
#include <string.h>
#include <conio.h>
#include <time.h>
#include "../include/spi.h"
#include "../include/rtc.h"

unsigned char DS1306(unsigned char v){
	return ((v / 10)<<4) | (v % 10);
}

void set_clock(struct tm *tm)
{   
	if(tm->tm_year<100 || tm->tm_year > 199){
		cprintf("invalid year, range 2000<=year<=2099, but was %d\n", tm->tm_year+1900);
		tm->tm_year = 2016 - 1900;//fallback set hard to 2016
	}	
    spi_select_rtc();
	spi_write(0x80);//write, start with seconds
	
    spi_write(DS1306(tm->tm_sec));//seconds
    spi_write(DS1306(tm->tm_min));//minutes
	spi_write(DS1306(tm->tm_hour) | 1<<7);//set clock, also 24h mode (bit 7)
	spi_write(1); //sunday
    spi_write(DS1306(tm->tm_mday));//day
	spi_write(DS1306(tm->tm_mon+1)); // ansi tm struct 0..11, correct DS1306 specific 1..12
	spi_write(DS1306(tm->tm_year-100)); // ansi tm struct year - 1900, correct DS1306 specific (year - 100)
	spi_deselect();
} 

unsigned int substr2int(unsigned char *s, unsigned short b, unsigned short l){
	unsigned short i;
	unsigned char t[5];
	for(i=0;i<l;i++){
		t[i] = s[b+i];
	}
	t[i] = '\0';
	//cprintf("%d %d %s\n",b, l, t);
	return atoi(t);
}

int main (int argc, char *argv[]){
	time_t t = _systime();
	if(argc > 1){
		struct tm *tm = localtime(&t);
		char *datestr = argv[1];
		unsigned short i = 0;
		if(strlen(datestr)>8){//assume date and time
			tm->tm_year  = substr2int(datestr, i, 4)-1900;i+=4;//year - 1900
			tm->tm_mon   = substr2int(datestr, i, 2)-1;i+=2;//0..11 for month
			tm->tm_mday  = substr2int(datestr, i, 2);i+=2;
		}
		tm->tm_hour  = substr2int(datestr, i, 2);i+=2;
		tm->tm_min   = substr2int(datestr, i, 2);i+=2;
		tm->tm_sec   = substr2int(datestr, i, 2);i+=2;
		//parse date from input
//		cprintf ("\n%d.%d.%d %d:%d:%d\n", tm->tm_mday, tm->tm_mon, tm->tm_year, tm->tm_hour, tm->tm_min, tm->tm_sec);
		set_clock(tm);
		t = _systime();
		cprintf("\nset to %s\n", asctime(localtime(&t)));
	}else
		cprintf("\nusage: %s [yyyymmdd]HHMMss\n", argv[0]);

    return EXIT_SUCCESS;
}