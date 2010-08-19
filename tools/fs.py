#! /usr/bin/python

# * This file is a part of the ogrp-os project
# * Version: 0.1 19 Aug 2010
#
# * Authors: jockepockee (jockepockee.com)
# * Email: jocke@h4xx.org
#
# * Copyright 2010 ogrp
# * License: see COPYING file

import sys

def main(argc, argv):
	if argc < 3:
		print "Usage:", str(argv[0]), "<command> <imagefile>\n"
		sys.exit(0)

	fp_img = open(argv[-1], "r+")

	fp_img.seek(512)
	str_ver = fp_img.read(8)

	print str_ver, "\n"

	while 1:
		byte = fp_img.read(1)

		if ord(byte) == 0:
			break

	if argv[1] == "list":
		while 1:
			filename = ""

			while 1:
				byte = fp_img.read(1)

				if ord(byte) == 0:
					break

				filename = str(filename + byte)

			print str(filename)

			fp_img.seek(1, 1)

			while 1:
				word = fp_img.read(2)
				if (ord(word[:-1]) + ord(word[-1:])) == 0:
					break

			byte = fp_img.read(1)
			if ord(byte) == 0:
				break

			fp_img.seek(-1, 1)
	
if __name__ == "__main__":
	main(len(sys.argv), sys.argv)

