#ifndef CKERNEL_TELETYPE_H__
#define CKERNEL_TELETYPE_H__

#include <types.h>

/* This is the textbuffer startaddress
 * in x86 based computers */
#define TEXTBUF 0xb800

/* Teletype prototypes */
void ckcur_update(void);
void ckputc_base(uint8_t c, uint8_t attr);
void ckprint(const char *str);
void ckclear(void);
void ckttyinit(void);

#endif
