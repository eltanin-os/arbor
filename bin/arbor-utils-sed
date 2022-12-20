#!/bin/execlineb -s1
backtick -Ex tmp { mktemp "XXXXXXXXX" }
foreground {
	redirfd -r 0 $1
	redirfd -w 1 $tmp
	sed $@
}
mv $tmp $1
