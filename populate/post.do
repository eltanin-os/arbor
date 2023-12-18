#!/bin/execlineb -S3
if {
	redirfd -w 1 chksum
	pipeline { find . -type f -name "*.pkg" }
	pipeline { cut -c3- } # strip "./"
	pipeline { sort }
	xargs venus-cksum
}
pipeline {
	cd datafiles
	venus-ar -c .
}
redirfd -w 1 database
importas -is DEFLATE DEFLATE
$DEFLATE
