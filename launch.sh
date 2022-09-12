#!/bin/sh
#
# Opens a development site URL from a site config file.

# Load from config file
FILE=ssdownload.conf
if test -f "$FILE"; then
    source $FILE
fi

# Open URL from DEVSITEURL config ite,
open $DEVSITEURL