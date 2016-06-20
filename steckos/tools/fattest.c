


#include <stdio.h>
#define BLOCK_SIZE 512

//
// od -Ax -t x1 --endian=little /dev/sdb|head -20

#define BS_Partition0	446

#define PE_Bootflag		 0
#define PE_CHSBegin		 1
#define PE_TypeCode		 4
#define PE_CHSEnd		 6
#define PE_LBABegin		 8
#define PE_NumSectors	 12

#define BPB_BytsPerSec 	 0xb
#define BPB_SecPerClus	 0xd
#define BPB_RsvdSecCnt	 0xe	// Number of reserved sectors. Should be 32 for FAT32
#define BPB_NumFATs		 0x10
#define BPB_Media		 21	// For removable media, 0xF0 is frequently used. 
						// The legal values for this field are 0xF0, 0xF8, 0xF9, 0xFA, 0xFB, 0xFC, 0xFD, 0xFE, and 0xFF. 
#define BPB_FATSz32		 0x24
#define BPB_RootClus	 0x2c
#define BS_BootSig		 38
#define BS_VolID		 39
#define BS_VolLab		 43
#define BS_FilSysType	 54	; One of the strings “FAT12 ”, “FAT16 ”, or “FAT ”.

int readBlock(unsigned char *buf, FILE *fd, unsigned long int address){
	unsigned long int offset = (address << 9);
	fpos_t pos;
	int s = fseek(fd, offset, SEEK_SET);
	fgetpos (fd, &pos);
	printf("offset: %d $%x pos: $%x\n", s, offset, pos);
	int n = fread(buf, 1, BLOCK_SIZE, fd);
	printf("%d\n",n);
	return n;
}

unsigned long long _32(unsigned char *buf, int offset){
//	return (buf[offset]<<16 | buf[offset+1]<<24 | buf[offset+2] | buf[offset+3]);
	return (buf[offset+3]<<24 | buf[offset+2]<<16 | buf[offset+1]<<8 | buf[offset]);
}

unsigned long _16(unsigned char *buf, int offset){
	return (buf[offset+1]<<8 | buf[offset]);
}

void dumpBuffer(unsigned char *buf){
	for(int n=0;n<BLOCK_SIZE;n++){
		if(n % 16 == 0)
			printf("\n%08x: ", n);
		printf("%02x ", buf[n]);
	}	
}

int main(int argc, char* argv[]){
	
	FILE *fd;
	int n;
	unsigned char buf[512];
	unsigned long long lba_addr;
	unsigned long int lba_begin;//sector number
	unsigned long v;

	unsigned long fat_begin_lba;
	unsigned long cluster_begin_lba;
	unsigned char sectors_per_cluster;
	unsigned long root_dir_first_cluster;

	
	fd = fopen("/dev/sdb", "r");
	if(fd==NULL){
		fprintf(stderr, "cannot open...");
		return 1;
	}
	
	n = readBlock(&buf[0], fd, 0);

	printf("Boot-Flag: %x\n", buf[BS_Partition0+PE_Bootflag]);
	printf("Type: $%02x\n", buf[BS_Partition0+PE_TypeCode]);
	v = _32(buf, BS_Partition0+PE_NumSectors);
	printf("Max Sectors: %u (%u MB)\n", v, (v*(unsigned long long)512/1024/1024));
	lba_begin = _32(buf, BS_Partition0+PE_LBABegin);
	printf("LBA-Begin: $%x\n", lba_begin);
	
	n = readBlock(&buf[0], fd, lba_begin);
	if(n != BLOCK_SIZE){
		printf("%d\n",n);
		return 1;
	}
	dumpBuffer(buf);
	
	printf("Volume-ID:\n");
	printf("Bytes/Sektor: %d\n", _16(buf, BPB_BytsPerSec));
	printf("Sektors/Cluster: %d\n", buf[BPB_SecPerClus]);
	printf("Res. Sectors: %d\n", _16(buf, BPB_RsvdSecCnt));
	printf("FATs: %d\n", buf[BPB_NumFATs]);
	printf("Sectors per FAT: %ld\n", _32(buf, BPB_FATSz32));
	printf("Root-Dir Cluster: %ld\n", _32(buf,BPB_RootClus));
	
	fclose(fd);
}