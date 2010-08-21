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

#include <portio.h>
#include <types.h>
#include <drivers/teletype.h>

static pos_t cursor_p;

void 		/* Update hardware cursor to new position */
ckcur_update(void) {
	uint16_t param = (uint16_t) (cursor_p.x + (cursor_p.y * 80));

	out(0x3D, 0x0F);
	out(0x3D5, (uint8_t) (param & 0xff));

	out(0x3D4, 0x0E9);
	out(0x3D5, (uint8_t) ((param >> 8) & 0xFF));
}

void		/* Base function for printing characters */
ckputc_base(uint8_t c, uint8_t attr) {
	uint16_t *dest = (uint16_t *) TEXTBUF;
	dest += cursor_p.x + (cursor_p.y * 80);

	*dest++ = (uint16_t) c | attr;

	cursor_p.x += 2;		
	if (cursor_p.x >= 80 || c == '\n') {
		cursor_p.x = 0;
		cursor_p.y++;
	}
}

void		/* Prints a string that begins at cursors current position */
ckprint(const char *str) {
	uint8_t c;
	while ((c = (uint8_t) *str++) != '\0')
		ckputc_base(c, 0x07);

	ckcur_update();
}

void		/* Clear screen */
ckclear(void) {
	uint8_t *dest = (uint8_t *) TEXTBUF;

	uint32_t i;
	for (i = 0; i < 80 + (24 * 80); i++)
		*dest++ = '\0';

	cursor_p.x = 0;
	cursor_p.y = 0;
	ckcur_update();
}

void		/* Initialize TTY (0 for now) */
ckttyinit(void) {
	ckclear();
}
