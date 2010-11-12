/*
; * This file is a part of the ogrp-os project
; * Version: 0.1 20 Aug 2010
;
; * Authors: jockepockee, mr3d (jockepockee.com, h4xxel.ath.cx)
; * Email: jocke@h4xx.org h4xxel@h4xx.org
;
; * Copyright 2010 ogrp
; * License: see COPYING file
 */

#include <types.h>
#include <portio.h>

void out(uint16_t port, uint8_t val) {
   __asm__ __volatile__ ("outb %0,%1"::"a"(val), "Nd" (port));
}

uint8_t in(uint16_t port) {
   uint8_t ret;
   __asm__ __volatile__ ("inb %1,%0":"=a"(ret):"Nd"(port));
   return ret;
}
