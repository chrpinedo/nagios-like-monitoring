#!/bin/sh

# Script for check_mk and Debian hosts to detect the availability of new
# updates.
# Christian Pinedo <chr.pinedo@gmail.com>

# Output of the script:
# - 0, OK: No updates
# - 1, WARNING: non-security updates available
# - 2, CRITICAL: security (and perhaps non-security) updates available

DEBIAN_CODENAME=$(lsb_release -cs)
SOURCE_LIST=/etc/apt/sources.list
SOURCE_LIST_D=/etc/apt/sources.list.d
TMP_SOURCE_LIST=/tmp/tmp.$$.sources.list

for file in $SOURCE_LIST $(find $SOURCE_LIST_D -type f -name *.list); do
    grep $DEBIAN_CODENAME/updates $file >> $TMP_SOURCE_LIST
done

apt-get -qq -o Dir::Etc::sourcelist=$TMP_SOURCE_LIST -o Dir::Etc::sourceparts="-" update
security=$(apt-get upgrade | tail -1 | cut -f 1 -d " ")
apt-get -qq update
total=$(apt-get upgrade | tail -1 | cut -f 1 -d " ")

if [ $security -ne 0 ]; then
        status=2
        statustxt=CRITICAL
        statusline="$statustxt - $security/$total security updates available"
elif [ $total -ne 0 ]; then
        status=1
        statustxt=WARNING
        statusline="$statustxt - $total updates available"
else
        status=0
        statustxt=OK
        statusline="$statustxt - System updated"
fi
echo "$status Debian_Updates security=$security;1;1;0;|total=$total;1; $statusline"
exit 0
