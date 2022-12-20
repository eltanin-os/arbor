#!/bin/execlineb -S3
importas -i ARBOR_PACKAGEDIR ARBOR_PACKAGEDIR
backtick cksum { arbor-priv-dbread cksum ${ARBOR_PACKAGEDIR}/package }
backtick urls { arbor-priv-dbread -t urls ${ARBOR_PACKAGEDIR}/package }
multisubstitute {
	importas -isu FETCH FETCH
	importas -iu cksum cksum
	importas -isu urls urls
}
foreground {
	forx -Ex 0 url { $urls }
	$FETCH $3 $url
}
backtick -Ex sum { arbor-priv-cksum $3 }
if -Xnt { test "${cksum}" =  "${sum}" }
arbor-utils-err "checksum mismatch"
