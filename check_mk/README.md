# Check\_MK's local checks

This folder provides several scripts developed for Check\_MK.

## Local Checks

### Introduction

This folder provides several local checks developed for Check\_MK.

Brief description of the scripts available:

* ubuntu.updates.sh: Monitor available updates in a Ubuntu hosts.
* debian.updates.sh: Monitor available updates in a Debian hosts. This script
  requires a cron job to be schedule periodically to refresh the apt-get
  database. This script is located under the  local-checks-cron folder and is
  called debian.updates.cron-task.sh.


### Install

1. Copy the desired script to the directory of the local checks usually
   */usr/lib/check\_mk\_agent/local*.

2. Give the script execution permissions.

3. Verify the output of the script with *check\_mk\_agent* command.
