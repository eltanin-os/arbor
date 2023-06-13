#!/bin/execlineb -S3
importas -i ARBOR ARBOR
cd $ARBOR
elglob repositories "./repo/*"
forx -E repo { $repositories }
if -t { test -d "${repo}" }
backtick -Ex name { basename $repo }
redo populate/${name}
