#!/bin/sh

# Script for setting up an exisitng Silverstripe site for local development
# Heavily modified from https://jeremy.hu/dev-environment-laravel-valet-wp-cli/.

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

set -e

shopt -s expand_aliases
source ~/.zshrc

# Enable nicer messaging.
BLUE_BOLD='\033[1;34m';
GREEN_BOLD='\033[1;32m';
RED_BOLD='\033[1;31m';
YELLOW_BOLD='\033[1;33m';
COLOR_RESET='\033[0m';
error () {
	echo "${RED_BOLD}$1${COLOR_RESET}"
}
status () {
	echo "${BLUE_BOLD}$1${COLOR_RESET}"
}
success () {
	echo "${GREEN_BOLD}$1${COLOR_RESET}"
}
warning () {
	echo "${YELLOW_BOLD}$1${COLOR_RESET}"
}

# Check ssdownload.conf exists
FILE=ssdownload.conf
if test -f "$FILE"; then
    # echo "$FILE exists."
	source $FILE
else
	# If it doesn't create an example to use:
	FILE_EXAMPLE=$FILE".example"
	touch $FILE_EXAMPLE
	# if  ! [ -s $FILE_EXAMPLE ]; then
		echo "REMOTEHOST=myserver.com" >> $FILE_EXAMPLE
		echo "USERNAME=example" >> $FILE_EXAMPLE
		echo "REMOTESITEROOT=www" >> $FILE_EXAMPLE
	# fi
	error "ssdownload.conf doesn't exist. I've created an example file for you to use."
	exit 0;
fi

status "➤ What do you want your site to be called? No Spaces, just lowercase letters please. (Hit enter to use: $USERNAME)"
read site_name
if [ "$site_name" == '' ]; then
	site_name="$USERNAME"
fi

site_url="http://$site_name.$VALET_DOMAIN/"
site_dir="$PWD"

status "➤ Is this a Silverstripe 3 or Silverstripe 4 site? (Default: 4)"
read silverstripe_version
if [ "$silverstripe_version" == '' ]; then
	silverstripe_version="4"
fi

# Set default PHP version for next step:
if [ "$silverstripe_version" == '4' ]; then
	default_php_version="$SS4_PHPV"
else
	default_php_version="$SS3_PHPV"
fi

status "➤ Which PHP version does this site require? (Default: $default_php_version)"
read php_version
if [ "$php_version" == '' ]; then
	php_version="$default_php_version"
fi

status "➤ Link the current working directory to Valet."
valet link $site_name


status "➤ Setting correct PHP version..."
# Check and create .valetphprc if necessary
if test -f ".valetphprc"; then
	status "➤ .valetphprc already exists"
else
	echo "php@$php_version" >> ".valetphprc"
	status "➤ Created .valetphprc"
fi
# Activate correct PHP:
valet use

status "➤ Running Composer install..."
composer install --prefer-dist

status "➤ Creating database..."
echo "CREATE DATABASE IF NOT EXISTS $site_name" | $DATABASE_CMD

status "➤ Setting up Silverstripe environment..."
SS4ENVFILE=.env
SS3ENVFILE=_ss_environment.php
VALETPHPRC=.valetphprc
# Check Silverstripe version
if [ "$silverstripe_version" == '4' ]; then # If Silverstripe 4:
	
	status "➤ Setting up Silverstripe 4 .env file..."
	# Create .env
	if ! test -f "$SS4ENVFILE" ; then
		status "➤ Creating .env..."
		touch $SS4ENVFILE
		cat << EOF >> .env
		SS_BASE_URL="https://$site_name.$VALET_DOMAIN"
		SS_ENVIRONMENT_TYPE="dev"

		SS_DATABASE_SERVER="$SS_DATABASE_SERVER"
		SS_DATABASE_NAME="$site_name"
		SS_DATABASE_USERNAME="$SS_DATABASE_USERNAME"
		SS_DATABASE_PASSWORD="$SS_DATABASE_PASSWORD"

		SS_DEFAULT_ADMIN_USERNAME="$SS_DEFAULT_ADMIN_USERNAME"
		SS_DEFAULT_ADMIN_PASSWORD="$SS_DEFAULT_ADMIN_PASSWORD"
EOF
	else 
		# Update an existing .env 
		status "➤ Updating existing .env..."
		sed -i '' -e 's,^SS_DATABASE_SERVER=.*$,SS_DATABASE_SERVER="127.0.0.1",' .env
		sed -i '' -e "s,^SS_DATABASE_NAME=.*$,SS_DATABASE_NAME=\"$site_name\"," .env
		sed -i '' -e 's,^SS_DATABASE_USERNAME=.*$,SS_DATABASE_USERNAME="root",' .env
		sed -i '' -e 's,^SS_DATABASE_PASSWORD=.*$,SS_DATABASE_PASSWORD="",' .env
	fi


else # If Silverstripe 3:

	status "➤ Setting up Silverstripe 3..."

		if ! test -f "_ss_environment.php" ; then
		status "➤ Creating _ss_environment.php..."
		touch _ss_environment.php
		cat << EOF >> _ss_environment.php
<?php
define('SS_ENVIRONMENT_TYPE', 'dev');

define('SS_DATABASE_SERVER', '$SS_DATABASE_SERVER');
define('SS_DATABASE_NAME', '$site_name');
define('SS_DATABASE_USERNAME', '$SS_DATABASE_USERNAME');
define('SS_DATABASE_PASSWORD', '$SS_DATABASE_PASSWORD');

define('SS_DEFAULT_ADMIN_USERNAME', '$SS_DEFAULT_ADMIN_USERNAME');
define('SS_DEFAULT_ADMIN_PASSWORD', '$SS_DEFAULT_ADMIN_PASSWORD');

\$_FILE_TO_URL_MAPPING['$site_dir'] = 'https://$site_name.$VALET_DOMAIN';
EOF
	else 
		# Update _ss_environment.php 
		status "➤ Updating _ss_environment.php..."
		sed -i '' -e "s,^define('SS_DATABASE_SERVER'.*$,define('SS_DATABASE_SERVER'\\, '$SS_DATABASE_SERVER');," _ss_environment.php
		sed -i '' -e "s,^define('SS_DATABASE_NAME'.*$,define('SS_DATABASE_NAME'\\, '$site_name');," _ss_environment.php
		sed -i '' -e "s,^define('SS_DATABASE_USERNAME'.*$,define('SS_DATABASE_USERNAME'\\, '$SS_DATABASE_USERNAME');," _ss_environment.php
		sed -i '' -e "s,^define('SS_DATABASE_PASSWORD'.*$,define('SS_DATABASE_PASSWORD'\\, '$SS_DATABASE_PASSWORD');," _ss_environment.php
	fi

fi

status "➤ Downloading site..."
ssdownload

status "➤ Setting up SSL certificate..."
valet secure $site_name

success "✓ Your site is ready! URL: $site_url"

# Open site in browser:
open $site_url

# Open site for editing:
$OPEN_IN_EDITOR_CMD

exit 0;