#ifndef _YM3812_H
#define _YM3812_H

extern unsigned char __fastcall__ opl2_read(void);

extern void __fastcall__ opl2_write(unsigned char val, unsigned char reg);

extern void __fastcall__ opl2_init(void);

/**
  @return 1 on success, 0 otherwise
 */
extern unsigned char __fastcall__ opl2_detect(void);

#endif 