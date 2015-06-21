/*
	Steckschwein serial transfer program
	usage:
		transfer -d /dev/cu.usbserial-FTAJMAUJ -a 0x1000 ../hello/hello.bin
*/

#include <stdio.h>     // Standard input/output definitions
#include <stdlib.h>     
#include <ctype.h>     
#include <string.h>    // String function definitions
#include <unistd.h>   // UNIX standard function definitions
#include <fcntl.h>      // File control definitions
#include <errno.h>     // Error number definitions
#include <termios.h>  // POSIX terminal control definitions 
#include <inttypes.h>

#define BUFSIZE 	65535
#define BAUDRATE	B115200

struct address
{
	uint8_t h;
	uint8_t l;
};


// function to open the port
int open_port(char * device)
{
          int port;
          //open the port and store the file descriptor in 'port'
          port = open(device, O_RDWR | O_NOCTTY | O_NDELAY);
          if (port == -1)
          {
                 // Could not open the port
                fprintf(stderr, "Error opening serial device %s: %s\n", device, strerror(errno));

          }
          else
          {
                fcntl(port, F_SETFL, 0); //leave this
          }
          return (port);
}

int main(int argc, char *argv[])
{
		char * device 		= NULL;
		char * filename 	= NULL;
		uint16_t startaddr 	= 0x1000;
    	uint16_t length;
		
    	int port,n,c,r;
		
		char buf[2];
		char buffer[BUFSIZE];
		char *end;

		device = getenv("SERIAL_DEVICE");

		opterr = 0;
		while ((c = getopt (argc, argv, "d:a:")) != -1)
		{
			switch (c)
			{
				case 'd':
					device = optarg;
					break;
				case 'a':
					startaddr = strtol(optarg, &end, 0);
					break;

			}
		}

		
		if (argc == optind)
		{
			fprintf(stderr, "No filename provided\n");
			return 1;	
		}

		filename = argv[argc - 1];

		if (! device)
		{
			fprintf(stderr, "No serial device provided\n");
			return 1;			
		}


		FILE *fp; // input file
		fp = fopen(filename, "r");
		if (!fp )
		{
			fprintf(stderr, "Error opening %s: %s\n", filename, strerror(errno));
			return 1;
		}

		length = fread(buffer, 1, sizeof(buffer), fp);
		fclose(fp);

		//termios - structure contains options for port manipulation
		struct termios specs; // for setting baud rate 

		//setup part
		port = open_port(device);
		if (port < 0)
		{
			return 1;
		}
		tcgetattr(port, &specs); 

		// printf("input: %x\n", specs.c_iflag);
		// printf("output: %x\n", specs.c_oflag);
		// printf("c: %x\n", specs.c_cflag);
		// printf("l: %x\n", specs.c_lflag);
		
		specs.c_lflag = (NOFLSH); //control flags
		//now the specs points to the opened port's specifications
		specs.c_cflag = (CLOCAL | CREAD ); //control flags
		
		specs.c_cflag &= ~PARENB;
		specs.c_cflag &= ~CSTOPB;
		specs.c_cflag &= ~CSIZE; /* Mask the character size bits */
		specs.c_cflag |= CS8; /* Select 8 data bits */


		//output flags
		//CR3 - delay of 150ms after transmitting every line
		specs.c_oflag = (OPOST | CR3 );
		specs.c_iflag = (IGNBRK);

		//set Baud Rate to 115200bps
		cfsetospeed(&specs,BAUDRATE);
		cfsetispeed(&specs,BAUDRATE);


		//our custom specifications set to the port
		//TCSANOW - constant that prompts the system to set
		//specifications immediately.
		tcsetattr(port,TCSANOW,&specs);
	
		// Send start address
		r = tcflush(port, TCIOFLUSH);
		n = write(port,&startaddr,2); // n = no of bytes written
		if (n<0) 
		{
		 	printf("\nError");
			return 1;
		}
		n = read(port, buf, 2);
		printf("%s", buf);
		if (strncmp(buf, "OK", 2) != 0)// only the 'O' could be read back :/
		{
			fprintf(stderr, "Error sending startaddr. Handshake %d\n", n);
			exit(1);
		}

		r = tcflush(port, TCIOFLUSH);
		n = write(port, &length,2); // n = no of bytes written
		if (n!=2) {
			printf("\nError sending length! Bytes written %d", n);
		}

		r = tcflush(port, TCIOFLUSH);
		n = read(port, buf, 2);
		printf("%s", buf);
		if (strncmp(buf, "OK", 2) != 0)
		{
			fprintf(stderr, "Error sending length. Handshake %d\n", n);
			exit(1);
		}

		printf("Sending $%04X bytes of data to $%04X\n", length, startaddr);

		r = tcflush(port, TCIOFLUSH);
		n = write(port, buffer, length);
		
		r = tcflush(port, TCIOFLUSH);
		read(port, buf, 2);
		if (strncmp(buf, "OK", 2) != 0)
		{
			fprintf(stderr, "Error sending data at byte %d\n", n);
			exit(1);
		}

		printf("$%04X (%d) bytes written.\n", n, n);

		//close the port
		close(port);
		return(0);
} 