#!/bin/sh

# Auxiliary script for the check_mk local script "debian.updates.sh".
# This script must be schedule periodically in the cron daemon.
# Christian Pinedo <chr.pinedo@gmail.com>

DEBIAN_CODENAME=$(lsb_release -cs)
SOURCE_LIST=/etc/apt/sources.list
SOURCE_LIST_D=/etc/apt/sources.list.d
TMP_SOURCE_LIST=/tmp/du.$$.sources
SECURITY_FILE=/tmp/du.security
GENERAL_FILE=/tmp/du.total

for file in $SOURCE_LIST $(find $SOURCE_LIST_D -type f -name *.list); do
	grep $DEBIAN_CODENAME/updates $file >> $TMP_SOURCE_LIST
done

apt-get -o Dir::Etc::sourcelist=$TMP_SOURCE_LIST -o Dir::Etc::sourceparts="-" update >/dev/null
date +%Y%m%d%H%M >$SECURITY_FILE
apt-get -s upgrade 2>/dev/null >>$SECURITY_FILE
rm $TMP_SOURCE_LIST

apt-get update >/dev/null
date +%Y%m%d%H%M >$GENERAL_FILE
apt-get -s upgrade 2>/dev/null >>$GENERAL_FILE

exit 0
