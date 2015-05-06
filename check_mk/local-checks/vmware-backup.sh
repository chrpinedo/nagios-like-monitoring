#!/bin/bash
# Christian Pinedo <chr.pinedo@gmail.com>

# Script to monitor vmware backups performed with ghettoVCB.sh
# https://communities.vmware.com/docs/DOC-8760

# Configuration variables
NFS_MOUNT_DIR=/backup
BACKUPS_DIR=$NFS_MOUNT_DIR/vmware
# if it is older than 20 days, old backup.
OLD_BACKUP=1728000

for vm in $(find $BACKUPS_DIR/* -maxdepth 0 -type d); do
	oIFS=$IFS
	IFS="
	"
	backups_dir=( $(find $vm/* -maxdepth 0 -type d | sort) )
	IFS=$oIFS
	backups=${#backups_dir[@]}
	last_index=$(expr $backups - 1)
	last_fail=
	last_old=
	fail_backups=0
	status=3
	statustxt="UNKNOWN - unknown state"
	# is there one backup??
	if [ $backups -eq 0 ]; then
		status=2
		statustxt="CRITICAL - No backup"
	# if there is at least one backup
	else
		for index in $(seq 0 $last_index); do
			if [ ! -f ${backups_dir[$index]}/STATUS.ok ]; then
				fail_backups=$(expr $fail_backups + 1)
				if [ $index -eq $last_index ]; then
					last_fail=1
				fi
			fi
			if [ $index -eq $last_index ]; then
				now_date=$(date +"%s")	
				tmp_date=$(basename ${backups_dir[$index]})
				tmp_date=${tmp_date#*-}
				tmp_date=${tmp_date%_*}
				last_date=$(date -d $tmp_date +"%s")
				dif_date=$(expr $now_date - $last_date)
				if [ $dif_date -gt $OLD_BACKUP ]; then
					last_old=1
				fi
			fi
		done
		if [ $backups -eq $fail_backups ]; then
			status=2
			statustxt="CRITICAL - All backups failed ($fail_backups/$backups)"
		elif [ -z "$last_fail" ] && [ -n "$last_old" ]; then
			status=2
			statustxt="CRITICAL - Last backup too old ($tmp_date) ($fail_backups/$backups)"
		elif [ -n "$last_fail" ] && [ -n "$last_old" ]; then
			status=2
			statustxt="CRITICAL - Last backup too old ($tmp_date) and failed ($fail_backups/$backups)"
		elif [ -n "$last_fail" ]; then
			status=1
			statustxt="WARNING - Last backup failed ($fail_backups/$backups)"
		elif [ $fail_backups -gt 0 ] && [ -z "$last_fail" ]; then
			status=1
			statustxt="WARNING - Some old backups failed ($fail_backups/$backups)"
		else 
			status=0
			statustxt="OK - All backups ok ($fail_backups/$backups)"
		fi
	fi
	echo "$status VmwareBackup_$(basename $vm) - $statustxt"
done
