#!/bin/bash

# Resolve links: $0 may be a link
app_path=$0

# Need this for daisy-chained symlinks.
while
    APP_HOME=${app_path%"${app_path##*/}"}  # leaves a trailing /; empty if no leading path
    [ -h "$app_path" ]
do
    ls=$( ls -ld "$app_path" )
    link=${ls#*' -> '}
    case $link in             #(
      /*)   app_path=$link ;; #(
      *)    app_path=$APP_HOME$link ;;
    esac
done

APP_HOME=$(cd "${APP_HOME:-./}" && pwd -P) || exit

echo "$ ln -s ${APP_HOME}/apply.sh /usr/local/bin/terraform-apply"
sudo ln -s "${APP_HOME}/apply.sh" /usr/local/bin/terraform-apply

echo "$ ln -s ${APP_HOME}/destroy.sh /usr/local/bin/terraform-destroy"
sudo ln -s "${APP_HOME}/destroy.sh" /usr/local/bin/terraform-destroy

echo "Installed scripts as local executables: terraform-apply & terraform-destroy!"
