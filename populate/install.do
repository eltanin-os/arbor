#!/bin/execlineb -S3
importas -i ARBOR ARBOR
multisubstitute {
	define CACHEDIR "../../cache"
	define PKGDIR "${ARBOR}/populate"
	importas -i REPODIR REPODIR
}
if { mkdir -p $REPODIR }
cd $REPODIR
if -t { test -f "${PKGDIR}/chksum" }
if {
	if {
		# do not override previous data
		redirfd -a 1 chksum
		cat ${PKGDIR}/chksum
	}
	arbor-priv-pkgexplode ${PKGDIR}/database
}
if { mkdir -p $CACHEDIR }
cd $CACHEDIR
find ${PKGDIR} -name "*.pkg" -exec
    define package "{}"
    backtick -Ex file { basename $package }
    backtick -Ex chksum { venus-conf $file ${PKGDIR}/chksum }
    cp $package ./${chksum}.${file}
    ;
