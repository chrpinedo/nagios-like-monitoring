# Check\_MK's local checks

## Introduction

This folder provides several local checks developed for Check\_MK.

Brief description of the scripts available:

* ubuntu.updates.sh: Monitor available updates in a Ubuntu hosts.
* debian.updates.sh: Monitor available updates in a Debian hosts.

## Install

1. Copy the desired script to the directory of the local checks usually
   */usr/lib/check\_mk\_agent/local*.

2. Give the script execution permissions.

3. Verify the output of the script with *check\_mk\_agent* command.
