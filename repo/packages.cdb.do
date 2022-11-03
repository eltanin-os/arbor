#!/bin/execlineb -S3
importas -i ARBOR ARBOR
pipeline { cd $ARBOR find -L repo -type f -name package }
pipeline { arbor.priv.cdbformat }
arbor.priv.cdbmake $3
