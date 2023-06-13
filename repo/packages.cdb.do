#!/bin/execlineb -S3
if { redo-always }
pipeline {
	importas -i ARBOR ARBOR
	find -L ${ARBOR}/repo -type f -name package
}
pipeline { arbor-priv-cdbformat }
arbor-priv-cdbmake $3
