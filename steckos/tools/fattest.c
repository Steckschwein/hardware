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

unsigned char block_fat[BLOCK_SIZE];
unsigned char block_data[BLOCK_SIZE];

struct partition_entry{
	unsigned char Bootflag;
	unsigned int TypeCode;
	unsigned long int NumSectors;
	unsigned long int LBABegin;
};

struct f32_volume{
	unsigned int BytsPerSec;
	unsigned char SecPerClus;
	unsigned int RsvdSecCnt;
	unsigned char NumFATs;
	unsigned long int FATSz32;
	unsigned long int RootClus;
	
	unsigned long int LbaFat;
	unsigned long int LbaCluster;
};

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
	int i = 0;
	int n = 0;
	for(;n<16;n++){
		int offs = n*32;
		if(buf[offs] == 0)//end of dir
			break;
	//	if(buf[offs] == 0xe5)//deleted?
	//		continue;			
		if(buf[offs+11] == 0x0f)//long file name?
			continue;
		dumpDirEntry(buf, offs);
		i++;
	}	
	return i;
}

struct fat_page{
	unsigned long int cluster_nr;
};

unsigned long int findFreeCluser(FILE *fd, struct f32_volume *vol){
	unsigned long int cluster = 0;
	unsigned int fbnr = 0;
	unsigned int i;
	l1: 
	for(;fbnr<vol->FATSz32;fbnr++){
		unsigned int n = readBlock(block_fat, fd, vol->LbaFat + fbnr);
		for (i=0;i<BLOCK_SIZE;i+=4){//+4 -> 32 bit cluster nr
			if(block_fat[i] == 0x0 && block_fat[i+1] == 0x0 && block_fat[i+2] == 0x0 && block_fat[i+3] == 0x0){//free cluster is marked with 0 0 0 0
				cluster = i;
				break;
			}
		}		
		break;
	}	
	printf("free cluster: block: $%x ix: $%x\n", fbnr, i);
	dumpBuffer(block_fat);
	return cluster;
}

void map(unsigned char *buf, struct partition_entry *p){
	p->Bootflag = buf[BS_Partition0+PE_Bootflag];
	p->TypeCode = buf[BS_Partition0+PE_TypeCode];
	p->NumSectors = _32(buf, BS_Partition0+PE_NumSectors);
	p->LBABegin = _32(buf, BS_Partition0+PE_LBABegin);
}

void buildVolumeData(unsigned char *buf, unsigned long int lba_begin, struct f32_volume *p){
	p->BytsPerSec = _16(buf, BPB_BytsPerSec);
	p->SecPerClus = buf[BPB_SecPerClus];
	p->RsvdSecCnt = _16(buf, BPB_RsvdSecCnt);
	p->NumFATs = buf[BPB_NumFATs];
	p->FATSz32 = _32(buf, BPB_FATSz32);
	p->RootClus = _32(buf,BPB_RootClus);
	
	p->LbaFat = lba_begin + p->RsvdSecCnt;
	//align LbaCluster upon root cluster cause 
	//lba_addr = cluster_lba + (cluster# - BPB_RootClus) * Sektoren/Cluster and therefore
	//lba_addr = cluster_lba - (BPB_RootClus * Sektoren/Cluster) + (cluster# * Sektoren/Cluster)
	unsigned long int align = (p->RootClus * p->SecPerClus);
	p->LbaCluster = p->LbaFat + (p->FATSz32 * p->NumFATs) - align;
}

unsigned long int inc32(unsigned long int lba_addr){
		return ++lba_addr;
}

unsigned long int calcFatLbaAddress(struct f32_volume *vol, unsigned long int cluster_nr){
	return vol->LbaFat + (cluster_nr>>7);// div 128 -> 4 (32bit) * 128 cluster numbers per block (512 bytes)
}

unsigned long int calcDataLbaAddress(struct f32_volume *vol, unsigned long int cluster_nr){
	return vol->LbaCluster + (cluster_nr * vol->SecPerClus);
}

int main(int argc, char* argv[]){
	
	FILE *fd;
	int n;
	struct partition_entry pe;
	struct f32_volume vol;
	
	unsigned long int data_lba_addr;
	unsigned long int fat_lba_addr;
	unsigned long int cluster_nr;	
	
	fd = fopen("/dev/sdb", "rw+");
	if(fd==NULL){
		fprintf(stderr, "cannot open...");
		return 1;
	}
	
	//read partition block 0
	n = readBlock(block_data, fd, 0);
	if(n != BLOCK_SIZE){
		printf("%d\n",n);
		return 1;
	}
	map(block_data, &pe);
	
	printf("Boot-Flag: %x\n", pe.Bootflag);
	printf("Type: $%02x\n", pe.TypeCode);
	printf("Max Sectors: %u (%u MB)\n", pe.NumSectors, (pe.NumSectors*(unsigned long long)512/1024/1024));
	printf("LBA-Begin: $%x\n", pe.LBABegin);
	
	n = readBlock(block_data, fd, pe.LBABegin);//volume id
	if(n != BLOCK_SIZE){
		printf("%d\n",n);
		return 1;
	}
	buildVolumeData(block_data, pe.LBABegin, &vol);
	
	printf("Volume-ID:\n");
	printf("Bytes/Sektor: %d\n", vol.BytsPerSec);
	printf("Sektors/Cluster: $%x (%d)\n", vol.SecPerClus, vol.SecPerClus);
	printf("Res. Sectors: $%x (%d)\n", vol.RsvdSecCnt, vol.RsvdSecCnt);
	printf("FATs: %d\n", vol.NumFATs);
	printf("Sectors per FAT: $%x (%ld)\n", vol.FATSz32, vol.FATSz32);
	printf("Root-Dir Cluster: %ld\n", vol.RootClus);	
	printf("lba_fat: $%x ($%x + $%x)\n", vol.LbaFat, pe.LBABegin, vol.RsvdSecCnt);
	printf("lba_cluster: $%x ($%x + ($%x * $%x))\n", vol.LbaCluster, vol.LbaFat, vol.FATSz32, vol.NumFATs);
	
	printf("Reading Root-Dir (cnr $%x)...\n", vol.RootClus);
	data_lba_addr = calcDataLbaAddress(&vol, vol.RootClus);
	int e=0;
	int r;
	//FIXME works only cause we have 512 Bytes/Sektor and 512 byte per sd-card block otherwise we have to do more calculation
	for(int i=0;i<vol.SecPerClus;i++){//
		unsigned long int o = data_lba_addr + i;
		//printf("lba-data: $%x\n", o);
		n = readBlock(block_data, fd, o);
		if(n != BLOCK_SIZE){
			printf("Error: %d\n",n);
			return 1;
		}
//		dumpBuffer(block_data);
		r = dumpDirEntries(block_data);
		if(r == 0)
			break;
		e += r;
	}
	printf("dir entries: %d\n", e);
	/* 0xdef -> 0xdf0 -> f0 0d 00 00 on disk
	ff ff ff 0f ff ff ff 0f ff ff ff 0f f0 0d 00 00
	000001c0: f1 0d 00 00 f2 0d 00 00 f3 0d 00 00 f4 0d 00 00
	000001d0: f5 0d 00 00 f6 0d 00 00 f7 0d 00 00 f8 0d 00 00
	000001e0: f9 0d 00 00 fa 0d 00 00 fb 0d 00 00 fc 0d 00 00
	000001f0: fd 0d 00 00 fe 0d 00 00 ff 0d 00 00 00 0e 00 00
	*/
	unsigned long int cla = 0x5f;//0xdef;//0xca;
	printf("fat cla: $%x $%x bn: $%x\n", cla, (cla << 2) - (cla >> 7 << 9), (cla >> 7));	
	fat_lba_addr = calcFatLbaAddress(&vol, cla);
	n = readBlock(block_data, fd, fat_lba_addr);
	if(n != BLOCK_SIZE){
		printf("Error: %d\n",n);
		return 1;
	}
	
	dumpBuffer(block_data);
	
	printf("data:\n");
	data_lba_addr = calcDataLbaAddress(&vol, cla);
	printf("data sector nr $%x, read $%x blocks:\n", cla, vol.SecPerClus);		
	for(unsigned int i=0;i<vol.SecPerClus;i++){
		n = readBlock(block_data, fd, data_lba_addr);
		if(n != BLOCK_SIZE){
			printf("Error: %d\n",n);
			return 1;
		}
		//dumpBuffer(block_data);
		
		data_lba_addr = inc32(data_lba_addr);
	}
		
	
//	cluster_nr = findFreeCluser(fd, &vol);	
//	printf("create root dir entry");	
	
	fclose(fd);
}