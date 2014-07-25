#include <stdio.h>
#include <string.h>
#include <stdlib.h>
#include <ctype.h>


void usage() {
	fprintf(stderr, "\t%s\n", "input <command and arguments> - as hex string, e.g. \"08efefa001\"");
}

/**
* @param data
* @param offset
* @param len
*/
unsigned short crc7(unsigned short *data, int offset, int len) {
	unsigned short crc = 0;
	int i = 0;
	for (i = 0; i < len; i++) {
		int x;
		for (x = 7; x >= 0; x--) {
			crc <<= 1;
			crc |= ((data[offset + i] >> x) & 1);
			if ((crc & 0x80) == 0x80) {
				crc ^= 0x89;
			}
		}
	}
	int x;
	for (x = 0; x < 7; x++) {
		crc <<= 1;
		if ((crc & 0x80) == 0x80) {
			crc ^= 0x89;
		}
	}
	return crc;
}


unsigned short hex2int(char *str, unsigned short dfl) {
	char HEX_digits[16] = { '0', '1', '2', '3', '4', '5', '6', '7', '8', '9', 'a', 'b', 'c', 'd', 'e', 'f' };
	int i, j;
	char c, k, shift;
	unsigned short tmp = 0;

	shift = 0;
	for (i = 1; i >= 0; i--) {
		if (!isxdigit(str[i])) {
			tmp = dfl;
			break;
		}
		c = tolower(str[i]);
		for (j = 0; j < 16; j++) {
			if (c == HEX_digits[j]) k = j;
		}
		tmp |= ((k & 0xf) << shift);
		shift += 4;
	}
	return tmp;
}



int main(int argc, char *argv[]){
	if (argc < 2 || strlen(argv[1]) != 10) {
		usage();
		exit(1);
	}
	unsigned short data[] = { 0, 0, 0, 0, 0 };

	int i;
	char hexstr[2];
	for (i = 0; i < 5; i++){
		strncpy(hexstr, argv[1]+i*2, 2);
		data[i] = hex2int(hexstr, 0x0000);
	}
	data[0] = data[0] | 0b01000000;// sd start bits

	unsigned short crc = crc7(data, 0, 5)<<1;
	for (i = 0; i < 5;i++)
		printf("$%02x,", data[i]);
	printf("$%02x\n", crc | 0x01);//sd stop bit
	
}
