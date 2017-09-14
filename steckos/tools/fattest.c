#include <errno.h>
#include <string.h>
#include <stdlib.h>
#include <stdio.h>
#include <sys/time.h>
#define BLOCK_SIZE 512
#define DIR_ENTRIES_PER_BLOCK BLOCK_SIZE / 32
#define DIRENTRY_FILENAME 11
#define EOC 0x0ffffff8 //end of cluster chain is everything greater or equal to 0x0ffffff8 - 24 Bit cluster number on fat32, the highest 4 bits are reserved and will be unmask

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

extern int errno;

struct PartitionEntry{
	unsigned char Bootflag;
	unsigned int TypeCode;
	unsigned long int NumSectors;
	unsigned long int LBABegin;
};

struct F32_Volume{
	unsigned int BytsPerSec;
	unsigned char SecPerClus;
	unsigned int RsvdSecCnt;
	unsigned char NumFATs;
	unsigned long int FATSz32;
	unsigned long int RootClus;
	
	unsigned long int LbaFat;
	unsigned long int LbaCluster;
};

struct F32_fd{
	unsigned char filename[12];
	unsigned char attr;
	unsigned long int startCluster;
	unsigned long int size;
	
	unsigned long int currentCluster;
	unsigned long int seekPos;
};

int readBlock(unsigned char *buf, FILE *fd, unsigned long int lba_addr){
	unsigned long int offset = (lba_addr << 9);//  fileOffset => lba_addr * 512
	fpos_t pos;
	int s = fgetpos (fd, &pos);
//	printf("lba: $%x offset: %d $%x pos: $%x\n", lba_addr, s, offset, pos);
	s = fseeko(fd, offset, SEEK_SET);
	if(s != 0){
		fprintf(stderr, "Error opening file: %s\n", strerror(errno));
		return s;
	}
	int n = fread(buf, 1, BLOCK_SIZE, fd);
	return n;
}

int writeBlock(unsigned char *buf, FILE *fd, unsigned long int lba_addr){
	unsigned long int offset = (lba_addr << 9);//  fileOffset => lba_addr * 512
	int s = fseeko(fd, offset, SEEK_SET);
	if(s != 0){
		fprintf(stderr, "Error opening file: %s\n", strerror(errno));
		return s;
	}
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

int match(char *s, char *s2){
	for(int i=0;i<DIRENTRY_FILENAME;i++){
		if(s[i] != s2[i])
			return 0;
	}
	return 1;
}

unsigned int findDirEntry(char* block_data, char *filename, struct F32_fd *fileFound){
	for(int n = 0;n<DIR_ENTRIES_PER_BLOCK;n++){
		int offs = n*32;
		if(block_data[offs] == 0)//end of dir
			return 0;
		if(block_data[offs] == 0xe5)//deleted?
			continue;
		if(block_data[offs+11] == 0x0f)//long file name?
			continue;
//		printf("%s <=> %s\n", &block_data[offs], filename);
		if(match(&block_data[offs], filename) == 1){
			printf("matched...\n");
			strncpy(fileFound->filename, filename, DIRENTRY_FILENAME);//filename
			fileFound->filename[11] = '\0';
			fileFound->attr = block_data[offs+11];
			fileFound->startCluster = (_16(block_data, offs+20) << 16) | _16(block_data, offs+26);
			fileFound->size = _32(block_data, offs+28);
			
			fileFound->currentCluster = fileFound->startCluster;
			fileFound->seekPos = 0;
			return 2;
		}
	}
	return 1;
}

int dumpDirEntry(unsigned char *buf, unsigned int offs){
	char tmp[12];
	strncpy(tmp, &buf[offs], 11);//filename
	tmp[11] = '\0';
	char fod = ((buf[offs+11] & 0x10) == 0 ? 'F' : 'D');
	char deleted = (buf[offs] == 0xe5 ? '-' : ' ');
	// files with size 0 - custer number in the directory should be zero. 
	// >= 0x0ffffff8- end of cluster chain
	unsigned long int cln = (_16(buf, offs+20) << 16) | _16(buf, offs+26);
	unsigned long int size = _32(buf, offs+28);
	printf("%c %c %11s $%x size: %ld, cln: $%x\n", deleted, fod, tmp, buf[offs+11], size, cln);
}

int dumpDirEntries(unsigned char *buf, unsigned int *cnt){
	int i = 0;
	int n = 0;
	for(;n<DIR_ENTRIES_PER_BLOCK;n++){
		int offs = n*32;
		if(buf[offs] == 0)//end of dir
			return 0;
	//	if(buf[offs] == 0xe5)//deleted?
	//		continue;			
		if(buf[offs+11] == 0x0f)//long file name?
			continue;
		dumpDirEntry(buf, offs);
		(*cnt)++;
	}
	return 1;
}

struct fat_page{
	unsigned long int cluster_nr;
};


void map(unsigned char *buf, struct PartitionEntry *p){
	p->Bootflag = buf[BS_Partition0+PE_Bootflag];
	p->TypeCode = buf[BS_Partition0+PE_TypeCode];
	p->NumSectors = _32(buf, BS_Partition0+PE_NumSectors);
	p->LBABegin = _32(buf, BS_Partition0+PE_LBABegin);
}

void buildVolumeData(unsigned char *buf, unsigned long int lba_begin, struct F32_Volume *p){
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

void inc32(unsigned long int *lba_addr){
	(*lba_addr)++;
}

unsigned long int calcFatLbaAddress(struct F32_Volume *vol, unsigned long int cluster_nr){
	return vol->LbaFat + (cluster_nr>>7);// div 128 -> 4 (32bit) * 128 cluster numbers per block (512 bytes)
}

unsigned long int calcDataLbaAddress(struct F32_Volume *vol, unsigned long int cluster_nr){
	return vol->LbaCluster + (cluster_nr * vol->SecPerClus);
}

int isEnd(unsigned long int cln){
	return ((cln & EOC) == EOC);
}

unsigned long long currentTimeMillis(){
	struct timeval te; 
    gettimeofday(&te, NULL); // get current time
    long long milliseconds = te.tv_sec*1000LL + te.tv_usec/1000; // caculate milliseconds
    return milliseconds;
}

unsigned long int nextClusterNumber(char *block_fat, unsigned long int cln){
	unsigned int offs = (cln << 2 & (BLOCK_SIZE-1));//offset within 512 byte block, cluster nr * 4 (32 Bit) and Bit 8-0 gives the offset
	unsigned long int nextCluster = _32(block_fat, offs);
//	printf("ncln: $%x\n", nextCluster);
	return nextCluster;
}

unsigned int findFreeCluser(FILE *fd, struct F32_Volume *vol){
	unsigned char found = 0;
	unsigned int fbnr;
	unsigned int boffs;
	
	for(fbnr = 0;found == 0 && fbnr<vol->FATSz32;fbnr++){//fat size in sectors == amount of blocks
		unsigned int n = readBlock(block_fat, fd, vol->LbaFat + fbnr);
		printf("search cluster, block: $%x\n", fbnr);
		for (boffs=0;boffs<BLOCK_SIZE;boffs+=4){//+4 -> 32 bit cluster nr
			if((block_fat[boffs+0]
			|	block_fat[boffs+1]
			|	block_fat[boffs+2]
			|	block_fat[boffs+3]) == 0x0){//free cluster is marked with 0 0 0 0
				printf("free cluster at block: $%x ix: $%x\n", fbnr, boffs);
				dumpBuffer(block_fat);
				found=1;
				break;
			}
		}
//		fgetc(stdin);
//		break;
	}
	dumpBuffer(block_fat);
	return boffs;
}

int show_dir(FILE *fd, struct F32_Volume *vol, unsigned long int dir_cln){
	unsigned long int data_lba_addr = calcDataLbaAddress(vol, dir_cln);
	unsigned int e=0;
	for(int i=0;i<vol->SecPerClus;i++){//
		unsigned int n = readBlock(block_data, fd, data_lba_addr);
		if(n != BLOCK_SIZE){
			printf("Error: %d\n",n);return 1;
		}
//		dumpBuffer(block_data);
		int r = dumpDirEntries(block_data, &e);		
		if(r == 0)//0 - eod
			break;
		inc32(&data_lba_addr);
	}	
	printf("dir entries: %d\n", e);
}

//int mkdir(FILE *fd, )

void error(FILE *f1, FILE *f2, int error){
	printf("Error: %d\n",error);
	fclose(f1);
	fclose(f2);
}

int main(int argc, char* argv[]){
	
	FILE *fd,*fd_out;
	struct PartitionEntry pe;
	struct F32_Volume vol;
	
	unsigned long int data_lba_addr;
	unsigned long int fat_lba_addr=0;
	unsigned long int fat_lba_addr_n=0;

	//dir entry
	//char filename[12] = "TESTDIR    \0";
	
//	char filename[12] = "32767   DAT\0";
	//char filename[12] = "32K     DAT\0";
	//char filename[12] = "32769   DAT\0";
	//char filename[12] = "511BYTE DAT\0";
//	char filename[12] = "512     DAT\0";
//	char filename[12] = "513BYTE DAT\0";
	//char filename[12] = "2048K   DAT\0";
//	char filename[12] = "1024K   DAT\0";
	//char filename[12] = "96K     DAT\0";
	char filename[12] = "8192K   DAT\0";
	//char filename[12] = "65536K  DAT\0";
/*	char filename[12] = "TEST    BIN\0";
	char filename[12] = "PIC1    CFG\0";
*/	
	fd = fopen("/dev/sdb", "r");
	if(fd==NULL){
		fprintf(stderr, "cannot open...");
		return 1;
	}
	fd_out = fopen("output.dat", "w");
	if(fd_out==NULL){
		fprintf(stderr, "cannot open...");
		return 1;
	}
	
	//read partition - block 0
	int n = readBlock(block_data, fd, 0);
	if(n != BLOCK_SIZE){
		error(fd, fd_out, n);
		return 1;
	}
	map(block_data, &pe);
	
	printf("Boot-Flag: %x\n", pe.Bootflag);
	printf("Type: $%02x\n", pe.TypeCode);
	printf("Max Sectors: %u (%u MB)\n", pe.NumSectors, (pe.NumSectors*(unsigned long long)512/1024/1024));//FIXME broken by design the sector size is not known at this time
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
	
	//FIXME works easily, cause we have 512 Bytes/Sektor and 512 byte per sd-card block otherwise we have to do more calculation
	unsigned long int dirCln = vol.RootClus;
	printf("Reading Root-Dir (cln: $%x)...\n", dirCln);
	unsigned int e=0;
    printf("Reading Root-Dir (cnr $%x)...\n", dirCln);
	
	show_dir(fd, &vol, dirCln);
	
	// ###################### find_first/find_next
	unsigned int r=-1;
	struct F32_fd fileFound;
	data_lba_addr = calcDataLbaAddress(&vol, dirCln);
	for(int i=0;i<vol.SecPerClus;i++){//
		n = readBlock(block_data, fd, data_lba_addr);
		if(n != BLOCK_SIZE){
			printf("Error: %d\n",n); return 1;
		}
		r = findDirEntry(block_data, filename, &fileFound);
		if(r == 0 || r== 2)//0 - eod or 2 - found
			break;
		inc32(&data_lba_addr);
	}
	printf("r: %d\n", r);
	if(r != 2){
		printf("%s not found!\n", filename);
		error(fd, fd_out, r);
		return 1;
	}
	printf("file '%s' found\n", fileFound.filename);
	
	// ###################### buffered read poc - fat_read for files with unlimited size (at least fat32 file size). uses only two 512 byte buffers (block_data/block_fat)
	/*
	unsigned long int ts = currentTimeMillis();
	unsigned long int cln = fileFound.startCluster;
	printf("fat cln: $%x boffs: $%x bnr: $%x\n", cln, (cln << 2 & (BLOCK_SIZE-1)), (cln >> 7));
	unsigned long int blocks = fileFound.size >> 9; //(div BLOCK_SIZE);
	if((fileFound.size & 0x1ff) != 0){
		blocks++;
	}
		
	l1: for(;!isEnd(cln) && blocks>0;){
		data_lba_addr = calcDataLbaAddress(&vol, cln);
		printf("data cluster nr $%x, $%x blocks to read, lba $%x\n", cln, blocks, data_lba_addr);
		//vol.SecPerClus <=> BLOCK_SIZE :) FTW!
		for(unsigned int i=0;i<vol.SecPerClus;i++){
			n = readBlock(block_data, fd, data_lba_addr);
			if(n != BLOCK_SIZE){
				error(fd, fd_out, n);
				return 1;
			}
			//dumpBuffer(block_data);
			n = fwrite(block_data, sizeof(char), BLOCK_SIZE, fd_out);
			if(n != BLOCK_SIZE){
				error(fd, fd_out, n);
				return 1;
			}
			if(--blocks == 0)
				goto l1;
			
			inc32(&data_lba_addr);
		}
		//
		fat_lba_addr_n = calcFatLbaAddress(&vol, cln);//lba address of cluster within fat
		if(fat_lba_addr != fat_lba_addr_n){
			printf("read fat block at fat lba: $%x\n", fat_lba_addr_n);
			int n = readBlock(block_fat, fd, fat_lba_addr_n);
			if(n != BLOCK_SIZE){
				error(fd, fd_out, n);
				return 1;
			}
			fat_lba_addr = fat_lba_addr_n;
			dumpBuffer(block_fat);
		}
		cln = nextClusterNumber(block_fat, cln);
	}
	
	ts = currentTimeMillis() - ts;
	printf("read %ld bytes took %ldms\n", fileFound.size, ts);
	*/
	
	unsigned int boffs = findFreeCluser(fd, &vol);
	
	fclose(fd);
	fclose(fd_out);
}