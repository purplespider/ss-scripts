#!/bin/sh
#
# Script to download SilverStripe assets & DB from server
#
# Usage:
# download-changes USERNAME REMOTEHOST
# download-changes naco slate

start=`date +%s`

# Display current date & time for starting reference
date

# Load from site config file
# 
# EXAMPLE ssdownload.conf
# REMOTEHOST=example.com
# USERNAME=example
# REMOTESITEROOT=public_html
#
FILE=ssdownload.conf
if test -f "$FILE"; then
    source $FILE
else
  # Get values as arguments
  USERNAME=$1
  REMOTEHOST=$2
  REMOTESITEROOT=${3:-/home/$USERNAME/public_html}
fi


if test -f "_ss_environment.php" ; then
  echo ' '
  echo '=================================='
  echo '** Syncing SS3 Assets:'
  echo '=================================='

  rsync --delete -av -e ssh $USERNAME@$REMOTEHOST:$REMOTESITEROOT/assets/ ./assets/
fi 

if test -f ".env" ; then
  echo ' '
  echo '=================================='
  echo '** Syncing SS4 Assets:'
  echo '=================================='

  rsync --delete -av -e ssh $USERNAME@$REMOTEHOST:$REMOTESITEROOT/public/assets/ ./public/assets/
fi

echo ' '
echo '=================================='
echo '** Removing Any Existing SSPak File:'
echo '=================================='

rm download.sspak
sleep 0.2s

echo ' '
echo '=============================='
echo '** Exporting DB to SSPak File:'
echo '=============================='

sspak save --db $USERNAME@$REMOTEHOST:$REMOTESITEROOT download.sspak

sleep 0.2s

echo ' '
echo '================================'
echo '** Importing DB from SSPak File:'
echo '================================'

sspak load --db download.sspak . --drop-db
sleep 0.2s

echo ' '
echo '========================'
echo '** Removing SSPak File:'
echo '========================'

rm download.sspak
sleep 0.2s

# Output time taken
echo ' '
echo "$USERNAME - Done in $((($(date +%s)-$start)/60)) minutes ($((($(date +%s)-$start))) secs)"
echo ' '