#!/bin/execlineb -S3
elglob repositories "./repo/*"
forx -E repo { $repositories }
if -t { test -d "${repo}" }
backtick -Ex name { basename $repo }
redo-ifchange populate/${name}
