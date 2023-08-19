#!/bin/execlineb -S3
importas -i ARBOR ARBOR
if { test -e "${ARBOR}/repo/${1}" }
if { mkdir -p $3 }
cd $3
if { mkdir -p dbfiles }
# create packages
if {
	backtick static {
		if {
			importas -i ARBOR_SANDBOX ARBOR_SANDBOX
			arbor-priv-createconfigfile
			    arbor.conf
			    ${ARBOR}/config/defaults
			    ${ARBOR}/config/${ARBOR_SANDBOX}
			    ${ARBOR}/repo/${1}/repo.conf
		}
		envfile arbor.conf
		if { rm arbor.conf }
		importas -D "" LDFLAGS LDFLAGS
		case -- $LDFLAGS {
			".*-static.*" { echo 1 }
		}
		echo 0
	}
	find -L ${ARBOR}/repo/${1} -type f -name "*.pkg" -exec
	    backtick -Ex file {
	    	backtick -Ex dir { dirname "{}" }
	    	basename $dir
	    }
	    redo-ifchange ${file}.pkg
	    ;
}
# create database
if {
	pipeline {
		cd dbfiles
		venus-ar -c .
	}
	redirfd -w 1 database
	lzip -9
}
# clean
rm -R dbfiles
