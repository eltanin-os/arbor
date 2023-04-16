#!/bin/execlineb -S3
importas -i ARBOR ARBOR
if { test -e "${ARBOR}/repo/${1}" }
if { mkdir -p $3 }
cd $3
if { mkdir -p dbfiles }
backtick -Ex static {
	if {
		arbor-priv-createconfigfile
		    arbor.conf
		    ${ARBOR}/config/defaults
		    ${ARBOR}/config/${ARBOR_SANDBOX}
		    ${ARBOR}/repo/${repo}/repo.conf
		    ${ARBOR_PACKAGEDIR}/config
	}
	envfile arbor.conf
	importas -D "" LDFLAGS LDFLAGS
	case -- $LDFLAGS {
	".*-static.*" { echo true }
	}
	echo false
}
backtick -xED "" plus { if -n { $static } echo "+" }
if {
	find -L ${ARBOR}/repo/$1 -type f -name "*.pkg" -exec
	    define pkg "{}"
	    backtick -Ex PKGDIR { dirname $pkg }
	    backtick ARBOR_PACKAGENAME { basename $PKGDIR }
	    foreground { arbor-utils-msg "populating..." }
	    ifelse { test -h "${PKGDIR}" } {
	    	backtick -Ex file { basename "${PKGDIR}" }
	    	ln -s $ARBOR_PACKAGENAME dbfiles/${file}
	    }
	    if {
	    	backtick packages {
	    		backtick name { arbor-priv-dbread name ${PKGDIR}/package }
	    		backtick version { arbor-priv-dbread version ${PKGDIR}/package }
	    		arbor-priv-splitpkg $pkg
	    	}
	    	redirfd -a 1 chksum
	    	importas -isu packages packages
	    	venus-cksum -w $packages
	    }
	    backtick -D "" makedeps {
	    	backtick -D "" deps { arbor-priv-dbread -t makedeps ${PKGDIR}/package }
	    	importas -isu deps deps
	    	forx -E dep { $deps }
	    	backtick -Ex version {
	    		backtick -Ex package {
	    			backtick -Ex pkgfile { arbor-priv-printpkgdep $dep }
	    			dirname $pkgfile
	    		}
	    		arbor-priv-dbread version ${ARBOR}/${package}/package
	    	}
	    	echo "${dep}#${version}${plus}"
	    }
	    pipeline {
	    	backtick -D "meta" version { arbor-priv-dbread version ${PKGDIR}/package }
	    	backtick -D "null" license { arbor-priv-dbread license ${PKGDIR}/package }
	    	backtick -D "null" description { arbor-priv-dbread description ${PKGDIR}/package }
	    	multisubstitute {
	    		importas -iu version version
	    		importas -iu license license
	    		importas -iu description description
	    	}
	    	heredoc 0 "
name:${name}
version:${version}
license:${license}
description:${description}
MAKEDEPS
RUNDEPS
"
	    	cat
	    }
	    importas -i ARBOR_PACKAGENAME ARBOR_PACKAGENAME
	    redirfd -w 1 dbfiles/${ARBOR_PACKAGENAME}
	    backtick -D "" rundeps { arbor-priv-dbread -t rundeps ${PKGDIR}/package }
	    multisubstitute {
	    	importas -iu makedeps makedeps
	    	importas -iu rundeps rundeps
	    }
	    awk -v"mdeps=${makedeps}" -v"rdeps=${rundeps}" -v"static=$static"
"
function cat(a1, a2, ac,    i) {
	for (i in a1) ac[length(ac) + 1] = a1[i]
	for (i in a2) ac[length(ac) + 1] = a2[i]
}
function arrsort(arr,     n) {
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
	true=1
	false=0
	p=1
}
/^MAKEDEPS/ {
	p=1
	if ($static) {
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
	if ($static) {
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
	    ;
}
if {
	cd dbfiles
	pipeline { venus-ar -c . }
	redirfd -w 1 ../database
	lzip -9
}
rm -Rf arbor.conf dbfiles
