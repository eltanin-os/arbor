#!/bin/execlineb -S1
importas -i ARBOR_PACKAGENAME ARBOR_PACKAGENAME
fdmove 1 2
foreground { arbor.utils.tput setaf 2 }
foreground { echo "arbor: <message> ${ARBOR_PACKAGENAME}: ${1}" }
foreground { arbor.utils.tput sgr0 }
exit 0
