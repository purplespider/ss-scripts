# Silverstripe Development Scripts

A handful of command line scripts to aid Silverstripe development (especially when using Laravel Valet as your dev environment):

* `ssdownload` - Download content (assets and database) from a live Silverstripe site
* `launch` - Open dev site URL in browser
* `newsite` - Creates a new Silverstripe site in Valet
* `setupsite` - Sets up an existing Silverstripe site for local development in Valet
* `deletesite` - Deletes a Valet site and matching database

## Script Installation & Setup

### macOS
1. Check out the repo to a location of your choice. e.g. to `~/Sites/_SS-SCRIPTS`
2. Make the scripts executable.
    ````bash
    cd ~/Sites/_SS-SCRIPTS
    chmod u+x *.sh
    ````
2. Copy `sssscripts.conf.example` to `sssscripts.conf` and customise as required.
3. Add aliases to the scripts, so they'll work anywhere, e.g. if using ZSH on mac OS:
    * Create/edit `~/.zshrc` and add the following, adjusting the path based on where you checked out the repo in step 1:
    ````bash
    alias newsite='~/Sites/_SS-SCRIPTS/newsite.sh'
    alias deletesite='~/Sites/_SS-SCRIPTS/deletesite.sh'
    alias setupsite='~/Sites/_SS-SCRIPTS/setupsite.sh'
    alias launch='~/Sites/_SS-SCRIPTS/launch.sh'
    ````

### Windows
These scripts were primarily created for macOS. You may need to make some adjustments for them to work on Windows.

## Add site configs

The `ssdownload` and `setupsite` scripts require some details about the site in question, such as the SSH conenction details. 

As you will likely wish to run `ssdownload` multiple times, these settings can be stored in a config file in your site's root:

__~/Sites/MYSITE/ssdownload.conf__
````
REMOTEHOST=example.com
USERNAME=example
REMOTESITEROOT=www

DEVSITEURL=https://example.dev/
````


## The Scripts
---

### `ssdownload` - Download content (assets and database) from a live Silverstripe site
Quickly update your local dev version of a site with the latest content and assets from the live site, by simply running `ssdownload` in the local site's root.

This script:
1. Uses `rsync` to pull down *only* changed/added assets.
2. Uses `sspak` to download a copy of the live database to replace the local database.

Local requirements:
* `sspak` [Download](https://github.com/silverstripe/sspak)
* `rsync`
* `ssdownload.conf` file in local site root with SSH details:
    * `REMOTEHOST = example.com`
    * `USERNAME = example`
    * `REMOTESITEROOT = www`
* OR: pass the 3 values as arguments, e.g.:
    * `ssdownload example example.com www`
* A working copy of a Silverstripe site (version 3 or 4)

Remote requirements:
* SSH access
    * With an existing public key setup

Usage:
* Once set up as above, simply run `ssdownload` from the site root and it will download the assets and database from the live site.

---

### `launch` - Open dev site in browser
Often forgetting the local dev URL for each of your sites? Just store it in `ssdownload.conf` and then run `launch` from the terminal to open it in your browser.

Requirements:
* `ssdownload.conf` in local site root with:
  * `DEVSITEURL = https://example.dev/`

Usage:
* `launch` from site root

---

### `newsite` - Creates a new Silverstripe site in Valet
Quickly spin up a fresh Silverstripe site in [Laravel Valet](https://laravel.com/docs/9.x/valet).

This script first prompts for:

1. A name for the site, e.g. `myexamplesite` (or takes it as an argument.)
2. Which version of Silverstripe you'd like to install, defaults to the latest.

Then it automatically:

1. Creates a new directory (using the entered name)for the site in `~/Sites` (Customisable in `ssscripts.conf`)
2. Links this directory as a Laravel Valet site.
2. Creates a new database for the site in your local database server. e.g. [DBngin](https://dbngin.com/)
4. Installs the desired Silverstripe version using Composer.
5. Sets Valet to use the appropriate PHP version (Customisable in `ssscripts.conf`)
5. Setups up the `.env` file for the site.
    * Adds database details
    * Adds default admin login details (Customisable in `ssscripts.conf`)
6. Runs `/dev/build` to set up the database.
7. Gives the site an SSL certificate using `valet secure`
8. Opens the local site URL in the browser.
9. Opens the site root in your editor ready for editing. (Customisable in `ssscripts.conf`)

Local requirements:
* [Laravel Valet](https://laravel.com/docs/9.x/valet)
* Database server (e.g. [DBngin](https://dbngin.com/))
* `composer`

---

### `deletesite` - Deletes a Valet site and database

If you used `newsite` to quickly spin up a new Silverstripe site to test/try something, you can quickly delete it by running:
````
deletesite NAMEOFSITE
````
This will then instantly:
1. Unlink the site directory from Valet.
2. Delete the site's directory.
3. Delete the site's database.

Requirements:
* Laravel Valet
* Database server (e.g. DBngin)

---

### `setupsite` - Sets up an existing Silverstripe site in Valet

If you have an __existing__ Silverstripe site that you'd like to get up and running in Valet, this script will take care of that by: adding the site to Valet, setting up the `.env` and downloading the assets and database from the live site.

1. Start in the root of a Silverstripe site, .e.g freshly checked out from a remote repository.
2. Add details for the remote site to a new `ssdownload.conf` file:
    * `REMOTEHOST=example.com`
    * `USERNAME=example`
    * `REMOTESITEROOT=www`
3. Run `setupsite` from the site root.

The script will ask:
1. For a name for the site, e.g. `myexamplesite` (Will default to the provided SSH username) 
2. Which version of Silverstripe the site is (e.g. 3 or 4)
3. Which PHP version the site requires. (Defaults to version set in `ssscripts.conf`)

Then it automatically:
1. Links this directory as a Laravel Valet site. (`valet link SITENAME`)
2. Sets Valet to use the desired PHP version.
3. Runs `composer install` to download required packages.
4. Creates a new database for the site in your local database server.
5. Creates a `.env` file prefilled with the local database details. (Or a `_ss_environment.php` for a Silverstripe 3 site.)
6. Runs `ssdownload` to get the site database and assets from the live site.
7. Gives the site an SSL cert using `valet secure`
8. Opens the local site URL in the browser.
9. Opens the site root in your editor ready for editing. (Customisable in `ssscripts.conf`)

Local requirements:
* Laravel Valet
* Database server (e.g. DBngin)
* `composer`

Also works with Silverstripe 3 sites, just make sure you have PHP 7.3 installed.
