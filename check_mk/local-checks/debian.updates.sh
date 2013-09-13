#!/bin/sh

# Script for check_mk and Debian hosts to detect the availability of new
# updates.
# To run this script you must also periodically run the cron job named
# "debian.updates.cron-task.sh".
# Christian Pinedo <chr.pinedo@gmail.com>

# Output of the script:
# - 0, OK: system updated
# - 1, WARNING: non-security updates available
# - 2, CRITICAL: security (and perhaps non-security) updates available
# - 3, UNKNOWN: required files are not available

SECURITY_FILE=/tmp/du.security
TOTAL_FILE=/tmp/du.total

status=3
statustxt=UNKNOWN
statusline="$statustxt - "

# Verify files
if [ ! -f $SECURITY_FILE -o ! -f $TOTAL_FILE ]; then
	status=3
	statustxt=UNKNOWN
	statusline="$statustxt - there are no required files."
	echo "$status Debian_Updates security=;1;1;0;|total=;1;;0; $statusline"
	exit 0
fi

# Process security file
security_date=$(head -1 $SECURITY_FILE)
security_number=$(grep "^Inst" $SECURITY_FILE | wc -l)
for file in $(grep "^Inst" $SECURITY_FILE | cut -d " " -f 2); do
	security_files="$security_files $file"
done

# Process total file
total_date=$(head -1 $TOTAL_FILE)
total_number=$(grep "^Inst" $TOTAL_FILE | wc -l)
for file in $(grep "^Inst" $TOTAL_FILE | cut -d " " -f 2); do
	total_files="$total_files $file"
done

# Output
if [ $security_number -ne 0 ]; then
        status=2
        statustxt=CRITICAL
        statusline="$statustxt - ($security_date) $security_number/$total_number security updates: $security_files"
elif [ $total_number -ne 0 ]; then
        status=1
        statustxt=WARNING
        statusline="$statustxt - ($total_date) $security_number/$total_number updates: $total_files"
else
        status=0
        statustxt=OK
        statusline="$statustxt - ($total_date) system updated"
fi
echo "$status Debian_Updates security=$security_number;1;1;0;|total=$total_number;1;;0; $statusline"
exit 0
