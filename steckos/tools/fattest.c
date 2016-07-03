#include <string.h>
#include <stdlib.h>
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

int readBlock(unsigned char *buf, FILE *fd, unsigned long int lba_addr){
	unsigned long int offset = (lba_addr << 9);//  fileOffset => lba_addr * 512
	fpos_t pos;
	int s = fseek(fd, offset, SEEK_SET);
	if(s != 0)
		return s;
//	fgetpos (fd, &pos);
//	printf("offset: %d $%x pos: $%x\n", s, offset, pos);
	int n = fread(buf, 1, BLOCK_SIZE, fd);
	return n;
}

int writeBlock(unsigned char *buf, FILE *fd, unsigned long int lba_addr){
	unsigned long int offset = (lba_addr << 9);//  fileOffset => * 512
	int s = fseek(fd, offset, SEEK_SET);
	if(s != 0)
		return s;
	int n = fwrite(buf, 1, BLOCK_SIZE, fd);
	return n;
}

unsigned long long _32(unsigned char *buf, int offset){
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
	printf("\n");
}

int dumpDirEntry(unsigned char *buf, unsigned int offs){
	char tmp[12];
	strncpy(tmp, &buf[offs], 11);//filename
	tmp[11] = '\0';
	char fod = ((buf[offs+11] & 0x10) == 0 ? 'F' : 'D');
	char deleted = (buf[offs] == 0xe5 ? '-' : ' ');
	// files with size 0 - custer number in the directory should be zero. 
	// >= 0x0ffffff8- end of cluster chain
	unsigned long int cla = (_16(buf, offs+20) << 16) | _16(buf, offs+26);
	unsigned long int size = _32(buf, offs+28);
	printf("%c %c %11s $%x size: %ld, cla: $%x\n", deleted, fod, tmp, buf[offs+11], size, cla);
}

int dumpDirEntries(unsigned char *buf){
	int n = 0;
	for(;n<16;n++){
		int offs = n*32;
		if(buf[offs] == 0)//end of dir
			break;
//		if(buf[offs] == 0xe5)//deleted?
	//		continue;			
		if(buf[offs+11] == 0x0f)//long file name?
			continue;			
		dumpDirEntry(buf, offs);
	}	
	return n;
}

int main(int argc, char* argv[]){
	
	FILE *fd;
	int n;
	unsigned char buf[512];
	unsigned char sec_per_cluster;
	unsigned int bytes_per_sec;
	unsigned char fat_count;
	unsigned long int lba_begin;//sector number
	unsigned long int sec_per_fat;
	unsigned long sec_reserved;
	unsigned long v;
	unsigned long int v_32;
	unsigned long int cluster_nr;
	
	unsigned long int lba_fat;
	unsigned long int lba_cluster;
	unsigned long lba_data;
	unsigned char sectors_per_cluster;
	unsigned long root_dir_first_cluster;

	
	fd = fopen("/dev/sdb", "rw+");
	if(fd==NULL){
		fprintf(stderr, "cannot open...");
		return 1;
	}
	
	n = readBlock(buf, fd, 0);

	printf("Boot-Flag: %x\n", buf[BS_Partition0+PE_Bootflag]);
	printf("Type: $%02x\n", buf[BS_Partition0+PE_TypeCode]);
	v = _32(buf, BS_Partition0+PE_NumSectors);
	printf("Max Sectors: %u (%u MB)\n", v, (v*(unsigned long long)512/1024/1024));
	lba_begin = _32(buf, BS_Partition0+PE_LBABegin);
	printf("LBA-Begin: $%x\n", lba_begin);
	
	n = readBlock(buf, fd, lba_begin);
	if(n != BLOCK_SIZE){
		printf("%d\n",n);
		return 1;
	}
//	dumpBuffer(buf);
	
	printf("Volume-ID:\n");
	bytes_per_sec = _16(buf, BPB_BytsPerSec);
	printf("Bytes/Sektor: %d\n", bytes_per_sec);
	sec_per_cluster = buf[BPB_SecPerClus];
	printf("Sektors/Cluster: $%x (%d)\n", sec_per_cluster, sec_per_cluster);
	sec_reserved = _16(buf, BPB_RsvdSecCnt);
	printf("Res. Sectors: $%x (%d)\n", sec_reserved, sec_reserved);
	lba_fat = lba_begin + sec_reserved;
	fat_count = buf[BPB_NumFATs];
	printf("FATs: %d\n", fat_count);
	sec_per_fat = _32(buf, BPB_FATSz32);
	printf("Sectors per FAT: $%x (%ld)\n", sec_per_fat, sec_per_fat);
	root_dir_first_cluster = _32(buf,BPB_RootClus);
	printf("Root-Dir Cluster: %ld\n", root_dir_first_cluster);
	
	printf("lba_fat: $%x ($%x + $%x)\n", lba_fat, lba_begin, sec_reserved);
	lba_cluster = lba_fat + (sec_per_fat * fat_count);
	printf("lba_cluster: $%x ($%x + ($%x * $%x))\n", lba_cluster, lba_fat, sec_per_fat, fat_count);
	
	printf("Reading Root-Dir (Cluster $%x)...\n", root_dir_first_cluster);
	lba_data = lba_cluster + ((root_dir_first_cluster - 2) * sec_per_cluster);
	int e=0;
	int r;
	for(int i=0;i<sec_per_cluster;i++){
		unsigned long int o = lba_data + i;
		//printf("lba-data: $%x\n", o);
		n = readBlock(buf, fd, o);
		if(n != BLOCK_SIZE){
			printf("Error: %d\n",n);
			return 1;
		}
//		dumpBuffer(buf);
		r = dumpDirEntries(buf);
		if(r == 0)
			break;
		e += r;
	}
	printf("dir entries: %d\n", e);
	
	unsigned long int cla = 0xca;	
	printf("fat cl: $%x $%x $%x\n", cla, (cla << 2) - (cla >> 7 << 9), (cla >> 7));
	n = readBlock(buf, fd, lba_fat + (cla >> 7));
	if(n != BLOCK_SIZE){
		printf("Error: %d\n",n);
		return 1;
	}
	dumpBuffer(buf);
	
	printf("data:\n");
	lba_data = lba_cluster + ((cla - 2) * sec_per_cluster);
	n = readBlock(buf, fd, lba_data);
	if(n != BLOCK_SIZE){
		printf("Error: %d\n",n);
		return 1;
	}
	dumpBuffer(buf);
	
	
	fclose(fd);
}