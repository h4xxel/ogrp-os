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

void ckmain(void);

#include <drivers/teletype.h>

void
ckmain(void) {
	/* Initialize TTY */
	ckttyinit();

	ckprint("Hello os-world!\n");
}

	
