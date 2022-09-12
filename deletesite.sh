#!/bin/sh

# Shell script to delete a specified Valet site, directory and database.
# Based on https://jeremy.hu/dev-environment-laravel-valet-wp-cli/

#########################################
### USAGE:
###
### deletesite
### deletesite mywebsite
#########################################

# Load config file 
SCRIPT=$(readlink -f "$0")
SCRIPT_PATH=$(dirname "$SCRIPT")
CONFIG_FILE=$SCRIPT_PATH"/ssscripts.conf"
if test -f "$CONFIG_FILE"; then
    source $CONFIG_FILE
else
  echo "Error: Missing ssscripts.conf in script directory: "$SCRIPT_PATH
  exit 0
fi


# Ask for site name to delete
if [ -z "$1" ]; then
	echo "Which site do you want to delete?"
    read site_name

# Or get from first argument
else
	site_name=$1
fi


# Change into sites dir
cd $SITES_PATH

echo "Unlinking site from Valet..."
valet unlink $site_name

echo "Deleting site directory..."
rm -rf $site_name

echo "Deleting site database..."
echo "DROP DATABASE IF EXISTS $site_name" | $DATABASE_CMD

echo "Done! Site deleted."

exit 0;