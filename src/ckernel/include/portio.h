#ifndef CKERNEL_PORTIO_H__
#define CKERNEL_PORTIO_H__

#include <types.h>

/* Port IO prototypes */
void out(uint16_t, uint8_t);
uint8_t in(uint16_t);

#endif
