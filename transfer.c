#include <stdio.h>
#include <stdlib.h>
#include <fcntl.h>  /* File Control Definitions          */
#include <termios.h>/* POSIX Terminal Control Definitions*/
#include <unistd.h> /* UNIX Standard Definitions         */
#include <errno.h>  /* ERROR Number Definitions          */
#include <sys/stat.h>

int main(int argc, char* argv[])
{
	if(argc <2){
		fprintf(stderr, "no file name given!");
		return 1;
	}
	char* filename = argv[1];
	char* devicePath;
	if((devicePath= getenv("TRANSFER_DEVICE")) ==NULL){
		devicePath = "/dev/ttyUSB0";
	}
	fprintf(stdout, "using device %s\n", devicePath);
	
	struct termios SerialPortSettings;
	FILE * fp;
	struct stat st;
	unsigned short address = 0x1000;
	unsigned short endaddress;
	unsigned char * buffer;
	unsigned short filesize;
	int fd;
	char read_buffer[32];                
	int  bytes_read = 0;                 
	int  bytes_written  =  0 ;   

	if(stat(filename, &st) == -1){
		perror("stat");
		exit(EXIT_FAILURE);
	}	
	filesize = st.st_size;
	endaddress = address + filesize;

	printf("load from $%x to $%x, size: %d\n", address, endaddress, filesize);
	
	buffer = malloc(filesize);

	fp = fopen(filename, "r");
	if (!fread(buffer, filesize, 1, fp))
	{
		fprintf(stderr, "Error opening or reading file.");
		return 1;
	}
	fclose(fp);

	fd = open(devicePath,O_RDWR | O_NOCTTY);
	if (!fd)
	{
		fprintf(stderr, "Error opening serial device.");
		return 1;
	}

  	tcgetattr(fd, &SerialPortSettings);
	cfsetispeed(&SerialPortSettings,B115200);
	cfsetospeed(&SerialPortSettings,B115200);

	SerialPortSettings.c_cflag &= ~PARENB;   // No Parity
	SerialPortSettings.c_cflag &= ~CSTOPB; //Stop bits = 1 

	SerialPortSettings.c_cflag &= ~CSIZE; /* Clears the Mask       */
	SerialPortSettings.c_cflag |=  CS8;   /* Set the data bits = 8 */

	SerialPortSettings.c_cflag &= ~CRTSCTS;

	SerialPortSettings.c_cflag |= CREAD | CLOCAL;

	SerialPortSettings.c_iflag &= ~(IXON | IXOFF | IXANY);
	SerialPortSettings.c_iflag &= ~(ICANON | ECHO | ECHOE | ISIG);

	/* Setting Time outs */                                       
	SerialPortSettings.c_cc[VMIN]  = 2; /* Read 10 characters */  
	SerialPortSettings.c_cc[VTIME] = 0;  /* Wait indefinitely   */

	tcsetattr(fd,TCSANOW,&SerialPortSettings);

	// start adress
	bytes_written = write(fd,&address,sizeof(address));
	printf("written: %d\n", bytes_written);
                             
	bytes_read = read(fd,&read_buffer,2);
	printf("read: %d, [%.2s]\n", bytes_read, read_buffer);

	// end adress
	bytes_written = write(fd,&endaddress,sizeof(endaddress));
	printf("written: %d\n", bytes_written);

	bytes_read = read(fd,&read_buffer,2);
	printf("read: %d, [%.2s]\n", bytes_read, read_buffer);

	bytes_written = 0;
	for(unsigned char * p = buffer; p <= buffer+filesize; p++)
	{
		bytes_written += write(fd, p, 1);
	}	
	printf("bytes written: %d\n", bytes_written);

	bytes_read = read(fd,&read_buffer,2);
	printf("read: %d, [%.2s]\n", bytes_read, read_buffer);


  	close(fd);
	free(buffer);
}
