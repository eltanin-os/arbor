#!/bin/execlineb -S3
if -nt { test -e $2 }
importas -i ARBOR ARBOR
backtick -Ex pkgdir {
	cd $ARBOR
	arbor-priv-cdbquery $2 repo/packages.cdb
}
ifelse { test -h "${pkgdir}" } {
	backtick -Ex name { arbor-priv-dbread name ${pkgdir}/package }
	if { redo-ifchange ../${name}.pkg }
	backtick -Ex version { arbor-priv-dbread version ${pkgdir}/package }
	if {
		if -t { test -h ${name}-dev }
		if { ln -s ${name} ${2}-dev }
		redo-ifchange ${2}-dev
	}
	if {
		if -t { test -h ${name}-dyn }
		if { ln -s ${name} ${2}-dyn }
		redo-ifchange ${2}-dyn
	}
	if -t { test -e $name }
	if { ln -s $name $2 }
	redo-ifchange $2
}
importas -i static static
backtick -D "" makedeps {
	backtick dyn { if -t { test "${static}" -eq "0" } echo "-dyn" }
	backtick plus { if -t { test "${static}" -eq "0" } echo "+" }
	backtick -D "" deps { arbor-priv-dbread -t makedeps ${pkgdir}/package }
	multisubstitute {
		importas -i ARBOR ARBOR
		importas -isu deps deps
		importas -iu dyn dyn
		importas -iu plus plus
	}
	forx -E dep { $deps }
	if { redo-ifchange ../${dep}.pkg }
	if { test -e ${dep}${dyn} }
	backtick -Ex version { arbor-priv-dbread version $dep }
	echo -n "${dep}${dyn}#${version}${plus} "
}
backtick -D "" rundeps {
	pipeline { arbor-priv-dbread -t rundeps ${pkgdir}/package }
	tr "\n" " "
}
backtick -Ex name { arbor-priv-dbread name ${pkgdir}/package }
pipeline {
	backtick -D "meta" version { arbor-priv-dbread version ${pkgdir}/package }
	backtick -D "null" license { arbor-priv-dbread license ${pkgdir}/package }
	backtick -D "null" description { arbor-priv-dbread description ${pkgdir}/package }
	multisubstitute {
		importas -iu version version
		importas -iu license license
		importas -iu description description
	}
	heredoc 0
"name:${name}
version:${version}
license:${license}
description:${description}
MAKEDEPS
RUNDEPS
"
	cat
}
redirfd -w 1 ${name}
multisubstitute {
	importas -ciu makedeps makedeps
	importas -iu rundeps rundeps
}
if {
	awk -v"mdeps=${makedeps}" -v"rdeps=${rundeps}" -v"static=${static}"
"
function cat(a1, a2, ac,    i) {
	for (i in a1) ac[length(ac) + 1] = a1[i]
	for (i in a2) ac[length(ac) + 1] = a2[i]
}
function arrsort(arr,      n) {
	for (i = 1; i <= n; i++) {
		for (j = 1; j <= n - i; j++) {
			if (arr[j] > arr[j + 1]) {
				tmp = arr[j]
				arr[j] = arr[j + 1]
				arr[j + 1] = tmp
			}
		}
	}
}
BEGIN{
	p=1
}
/^MAKEDEPS/ {
	p=1
	if (static) {
		split(mdeps, str, \" \")
		if (length(str) > 0) {
			print \"makedeps{\"
			arrsort(str)
			for (i in str) print str[i]
			print \"}\"
		}
	}
	p=0
}
/^RUNDEPS/ {
	p=1
	if (static) {
		split(rdeps, str, \" \")
	} else {
		split(mdeps, a1, \" \")
		split(rdeps, a2, \" \")
		cat(a1, a2, str)
	}
	if (length(str) > 0) {
		print \"rundeps{\"
		arrsort(str)
		for (i in str) print str[i]
		print \"}\"
	}
	p=0
}
p
"
}
redo-ifchange ${name}
