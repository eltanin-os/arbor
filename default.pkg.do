#!/bin/execlineb -S3
importas -i ARBOR ARBOR
if { redo-ifchange package }
# declare package info
backtick name { arbor-priv-dbread name package }
backtick -D "meta" version { arbor-priv-dbread version package }
multisubstitute {
	importas -iu name name
	importas -iu version version
}
export ARBOR_PACKAGENAME "${name}"
backtick -D "${name}-${version}" src { arbor-priv-dbread src package }
backtick -D "all" arch { arbor-priv-dbread -t arch package }
backtick -D "all" platforms { arbor-priv-dbread -t platforms package }
multisubstitute {
	importas -iu src src
	importas -iu arch arch
	importas -iu platforms platforms
}
# check if the package is available
if {
	ifelse { test "all" = "${arch}" } { exit 0 }
	exit 0
}
if {
	ifelse { test "all" = "${platforms}" } { exit 0 }
	exit 0
}
# set the dependencies
ifelse -Xn { arbor-priv-setdeps $name } { arbor-utils-err "failed to set deps" }
# meta package?
ifelse { test "meta" = "${version}" } {
	multisubstitute {
		importas -is ARCHIVE ARCHIVE
		importas -is DEFLATE DEFLATE
	}
	pipeline { echo -n }
	pipeline { $ARCHIVE }
	redirfd -w 1 $3
	$DEFLATE
}
if { redo-ifchange build }
# prepare the arbor build environment
backtick ARBOR_TMPTARGETDIR { arbor-priv-mktempdir }
backtick ARBOR_TMPSYSTEMDIR { arbor-priv-mktempdir }
backtick deps { arbor-priv-printpkgdeps -R $name }
multisubstitute {
	importas -i PWD PWD
	importas -i ARBOR_TMPTARGETDIR ARBOR_TMPTARGETDIR
	importas -i ARBOR_TMPSYSTEMDIR ARBOR_TMPSYSTEMDIR
	importas -isu deps deps
}
backtick -D "" ARBOR_PACKAGECONFIG {
	if -X { test "meta" = "${version}" }
	echo ${PWD}/config
}
export ARBOR_PACKAGEDIR "${PWD}"
export ARBOR_PACKAGESRC "${src}"
# prepare the package build environment and build
foreground {
	if {
		cd $ARBOR_TMPSYSTEMDIR
		foreground { arbor-utils-msg "deps..." }
		foreground { arbor-priv-pkgexplode ${ARBOR}/$deps }
		foreground { mkdir -p tmp }
		foreground {
			cd tmp
			foreground { arbor-utils-msg "fetch..." }
			backtick -Ex file { arbor-priv-geturlfilename }
			foreground { redo-ifchange $file }
			arbor-priv-explode $file
		}
		ifelse -Xn { importas -iu ? ? test "${?}" -eq "0" } { arbor-utils-err "failed to fetch" }
		foreground { arbor-priv-envprepare }
		foreground { arbor-utils-msg "build..." }
		foreground { arbor-priv-sandboxbuild }
		ifelse -Xn { importas -iu ? ? test "${?}" -eq "0" } { arbor-utils-err "failed to build" }
		cd tmp/output
		arbor-priv-postbuild
	}
	backtick -Ex tmpfile { mktemp }
	foreground { arbor-utils-msg "package..." }
	foreground { arbor-priv-pkgcreate $3 $ARBOR_TMPTARGETDIR }
}
importas -iu status ?
foreground { rm -Rf $ARBOR_TMPTARGETDIR $ARBOR_TMPSYSTEMDIR }
exit $status
