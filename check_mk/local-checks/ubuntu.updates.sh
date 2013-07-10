#!/bin/bash

# Script for check_mk and Ubuntu hosts to detect the availability of new
# updates.
# Christian Pinedo <chr.pinedo@gmail.com>
#
# This script is based on the work of David Schoen - http://lyte.id.au
# http://lyte.id.au/2011/04/07/checking-for-apt-security-updates-with-nagios/

# Output of the script:
# - 0, OK: No updates
# - 1, WARNING: non-security updates available
# - 2, CRITICAL: security (and perhaps non-security) updates available
# - 3, UNKNOWN: The apt_check.py is not available and it is required

APT_CHECK=/usr/lib/update-notifier/apt_check.py
if [ ! -x $APT_CHECK ]; then
	echo "3 Ubuntu_Updates - UNKNOWN - apt_check.py is not available"
	exit 0
fi

IFS=';' read -r total security < <($APT_CHECK 2>&1)
if [[ $security -ne 0 ]]; then
        status=2
        statustxt=CRITICAL
        statusline="$statustxt - $security/$total security updates available"
elif [[ $total -ne 0 ]]; then
        status=1
        statustxt=WARNING
        statusline="$statustxt - $total updates available"
else
        status=0
        statustxt=OK
        statusline="$statustxt - System updated"
fi
echo "$status Ubuntu_Updates security=$security;1;1;0;|total=$total;1; $statusline"
exit 0
