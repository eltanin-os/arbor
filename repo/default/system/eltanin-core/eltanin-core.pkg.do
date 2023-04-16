#!/bin/execlineb -S3
# If not a unique/rare exception, add the following to default.do:
# 1. Import $STAGE (0/1) and set it as $STAGE+1
# 2. If $STAGE = 0: pass the deps to redo-ifchange
# 3. If $STAGE = 1: return $(test -e $1)
# CAVEATS:
# 1. It must have no automatic cycles check
# 2. It must use a hash instead of timestamp check
backtick deps {
	redirfd -r 0 deps
	xargs -n1 arbor-priv-printpkgdep
}
multisubstitute {
	importas -i ARBOR ARBOR
	importas -isu deps deps
}
cd $ARBOR
if { redo $deps }
backtick -Ex tmpdir { arbor-priv-mktempdir }
foreground {
	cd $tmpdir
	if { arbor-priv-pkgexplode ${ARBOR}/${deps} }
	arbor-priv-pkgcreate $3 .
}
arbor-priv-freetempdir $tmpdir
