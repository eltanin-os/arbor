#!/bin/execlineb -S3
importas -i ARBOR ARBOR
if {
	# create packages
	find -L ${ARBOR}/repo -type f -name "*.pkg" -exec
	    backtick -Ex file {
	    	backtick -Ex dir { dirname "{}" }
	    	basename $dir
	    }
	    redo-ifchange $file
	    ;
}
redo-ifchange post
