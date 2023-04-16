#!/bin/execlineb -S3
backtick -Ex stdenv { arbor-priv-printpkgdep stdenv }
find repo -type f -name "package" -exec
    define pkg "{}"
    backtick -Ex dir { dirname $pkg }
    backtick -Ex name { venus-conf name $pkg }
    if -Xnt { test "${dir}/${name}.pkg" = "${stdenv}" }
    redo-ifchange ${dir}/${name}.pkg
    ;
