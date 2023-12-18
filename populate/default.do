#!/bin/execlineb -S3
backtick ARBOR_PACKAGEDIR {
	importas -i ARBOR ARBOR
	arbor-priv-cdbquery $1 ${ARBOR}/repo/packages.cdb
}
importas -i ARBOR_PACKAGEDIR ARBOR_PACKAGEDIR
# default header
backtick name { arbor-priv-dbread name ${ARBOR_PACKAGEDIR}/package }
backtick -D "meta" version { arbor-priv-dbread version ${ARBOR_PACKAGEDIR}/package }
backtick -D "null" license { arbor-priv-dbread license ${ARBOR_PACKAGEDIR}/package }
backtick -D "null" description { arbor-priv-dbread description ${ARBOR_PACKAGEDIR}/package }
# static?
# XXX: heuristic (alternative: heuristic per 'package' || reliable ldd)
backtick static {
	if { arbor-priv-createconfigfile arbor.conf }
	envfile arbor.conf
	if { rm arbor.conf }
	importas -D "" LDFLAGS LDFLAGS
	case -- $LDFLAGS {
		".*-static.*" { echo 1 }
	}
	echo 0
}
importas -i name name
if { rm -f ${name}-rundeps ${name}-makedeps }
# mdeps
if {
	importas -i static static
	backtick mdfile {
		ifelse { test "${static}" -eq "0" } {
			echo ${name}-rundeps
		}
		echo ${name}-makedeps
	}
	backtick dyn {
		if -t { test "${static}" -eq "0" }
		echo "-dyn"
	}
	backtick plus {
		if -t { test "${static}" -eq "0" }
		echo "+"
	}
	backtick -D "" deps { arbor-priv-dbread -t makedeps ${ARBOR_PACKAGEDIR}/package }
	multisubstitute {
		importas -iu mdfile mdfile
		importas -iu dyn dyn
		importas -iu plus plus
		importas -isu deps deps
	}
	redirfd -a 1 $mdfile
	forx -E dep { $deps }
	if { redo-ifchange $dep }
	if { test -e "datafiles/${dep}${dyn}" }
	backtick -Ex pkgver {
		backtick -Ex leaf { arbor-priv-leafpath $dep }
		importas -i ARBOR ARBOR
		arbor-priv-dbread version ${ARBOR}/${leaf}/package
	}
	echo "${dep}${dyn}#${pkgver}${plus}"
}
# rdeps
foreground {
	redirfd -a 1 ${name}-rundeps
	arbor-priv-dbread -t rundeps ${ARBOR_PACKAGEDIR}/package
}
# build
importas -i ARBOR ARBOR
${ARBOR}/populate/arbor-createpkg $1
