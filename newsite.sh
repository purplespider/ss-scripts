#!/bin/sh

# Shell script for creating Silverstripe sites with Valet.
# Based on https://jeremy.hu/dev-environment-laravel-valet-wp-cli/
# chmod u+x newsite.sh

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

# Start script:
set -e

cd $SITES_PATH;

# Check if site name has been provided as an argument, if not, prompt for it and ask for Silverstripe version
if [ -z "$1" ]; then
	status "➤ What do you want your site to be called? Used for directory, URL and database name. No Spaces, just lowercase letters please."
	read site_name

	status "➤ Which Silverstripe version would you like? (Hit enter for latest)"
	read ss_version
else
	site_name=$1
fi

site_url="http://$site_name.$VALET_DOMAIN/"

status "➤ Creating a new site directory..."
mkdir $site_name
cd $site_name

status "➤ Linking the directory to Valet..."
valet link

status "➤ Creating database..."
echo "CREATE DATABASE " $site_name | $DATABASE_CMD

status "➤ Installing Silverstripe..."
composer create-project silverstripe/installer . $ss_version

# Check and create .valetphprc if necessary
status "➤ Creating .valetphprc..."
echo "php@$SS4_PHPV" >> .valetphprc

status "➤ Setting up .env..."
mv .env.example .env

sed -i '' -e "s,^SS_DATABASE_SERVER=.*$,SS_DATABASE_SERVER=\"$SS_DATABASE_SERVER\"," .env
sed -i '' -e "s,^SS_DATABASE_NAME=.*$,SS_DATABASE_NAME=\"$site_name\"," .env
sed -i '' -e "s,^SS_DATABASE_USERNAME=.*$,SS_DATABASE_USERNAME=\"$SS_DATABASE_USERNAME\"," .env
sed -i '' -e "s,^SS_DATABASE_PASSWORD=.*$,SS_DATABASE_PASSWORD=\"$SS_DATABASE_PASSWORD\"," .env

cat << EOF >> .env
SS_DEFAULT_ADMIN_USERNAME="$SS_DEFAULT_ADMIN_USERNAME"
SS_DEFAULT_ADMIN_PASSWORD="$SS_DEFAULT_ADMIN_PASSWORD"
EOF

status "➤ Running Silverstripe dev/build..."
vendor/bin/sake dev/build

# status "➤ Secure with TLS (y/n)?"
# read answer

# if [ "$answer" != "${answer#[Yy]}" ] ;then
	status "➤ Setting up SSL certificate..."
	valet secure $site_name
# fi

success "✓ Your new site is ready! URL: $site_url"

# Open site in browser:
open $site_url

# Open site for editing:
$OPEN_IN_EDITOR_CMD

exit 0;