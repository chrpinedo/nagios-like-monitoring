#!/bin/sh
# Christian Pinedo <chr.pinedo@gmail.com>

# Configuration variables
RANCID_DIR="" # Where rancid's data is located, for example, "/var/lib/rancid"
RANCID_GROUPS="" # One or multiple groups of rancid to monitor, for example, "network" or "routers switches" or ...

for group in $RANCID_GROUPS; do
	status=3
	statustxt="UNKNOWN - No Rancid logs for $group"
	for log in `ls $RANCID_DIR/logs/$group.* 2>/dev/null`; do
		date=`echo $log | cut -d "." -f 2`
		today=`date +%Y%m%d`
		yesterday=`date +%Y%m%d -d "yesterday"`
		if [ "$date" = "$today" -o "$date" = "$yesterday" ]; then
			status=0
			statustxt="OK - Rancid for $group is running"
		elif [ "$status" = "3" ]; then
			status=2
			statustxt="CRITICAL - Rancid logs for $group older than 2 days"
		fi
	done
	echo "$status Rancid_${group}_state - $statustxt"
	for device in `cat $RANCID_DIR/$group/routers.all 2>/dev/null | cut -d ";" -f 1`; do
		status=3
		statustxt="UNKNOWN - $device is unknow to backup"
		if grep $device $RANCID_DIR/$group/routers.up >/dev/null 2>&1; then
			status=0
			statustxt="OK - $device is up to backup"
		fi
		if grep $device $RANCID_DIR/$group/routers.down >/dev/null 2>&1; then
			status=2
			statustxt="CRITICAL - $device is down to backup"
		fi
		echo "$status Rancid_${group}_${device} - $statustxt"
	done
done
