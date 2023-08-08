#!/bin/execlineb -S3
importas -i ARBOR ARBOR
backtick -Ex pkgdir {
	cd $ARBOR
	arbor-priv-cdbquery $2 repo/packages.cdb
}
backtick name { arbor-priv-dbread name ${pkgdir}/package }
backtick version { arbor-priv-dbread version ${pkgdir}/package }
multisubstitute {
	importas -i name name
	importas -i version version
}
if -nt {
	if -nt { test -e ${2}#${version}.pkg }
	if -nt { test -e ${2}-dev#${version}.pkg }
	test -e ${2}-dyn#${version}.pkg
}
if { redo-ifchange ${pkgdir}/package }
ifelse { test -h "${pkgdir}" } {
	if { redo-ifchange ${name}.pkg }
	redo-ifchange dbfiles/${2}.db
}
backtick files { arbor-priv-splitpkg ${pkgdir}/${2}.pkg }
multisubstitute {
	importas -iu version version
	importas -isu files files
}
if { redo-ifchange ${files}#${version}.pkg }
if {
	redirfd -a 1 chksum
	venus-cksum ${files}#${version}.pkg
}
if { forx -E file { $files } ln -s $name dbfiles/${file} }
if { rm -f dbfiles/${name} }
redo-ifchange dbfiles/${name}.db
