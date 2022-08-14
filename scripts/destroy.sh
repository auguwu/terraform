#!/bin/bash

set -o errexit
set -o nounset
set -o pipefail

join() {
  local IFS="$1"
  shift
  echo "$*"
}

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

. "$APP_HOME/lib/libbootstrap.sh"
. "$APP_HOME/lib/libkibana.sh"
. "$APP_HOME/lib/utils.sh"

check_if_cmds_exists
check_if_fluff_network_exists
feed_kibana_encryption_keys

echo "[::terraform] Destroying Terraform plan..."

TERRAFORM_ARGS=(
  "-var kibana_reporting_encryptionkey=${KIBANA_REPORTING_ENCRYPTIONKEY}"
  "-var kibana_security_encryptionkey=${KIBANA_SECURITY_ENCRYPTIONKEY}"
  "-var kibana_savedobjects_encryptionkey=${KIBANA_SAVEDOBJECTS_ENCRYPTIONKEY}"
  "-var kibana_service_token=${KIBANA_SERVICE_TOKEN}"
  "-var logstash_password=${LOGSTASH_PASSWORD:-noeliscutieuwu}"
  "-var logstash_username=${LOGSTASH_USERNAME:-noel}"
  "-var redis_password=${REDIS_PASSWORD:-noeliscutieuwu}"
)

if [[ -n "${TERRAFORM_ARGS:-}" ]]; then
  TERRAFORM_ARGS+=($TERRAFORM_ARGS)
fi

if [[ -n "${TERRAFORM_AUTO_APPLY:-}" ]]; then
  if [[ "${TERRAFORM_AUTO_APPLY}" =~ ^(yes|true|si|si*|1)$ ]]; then
    TERRAFORM_ARGS+=("-auto-approve")
  fi
fi

export JOINED_TERRAFORM_ARGS=$(join ' ' "${TERRAFORM_ARGS[@]}")
exec terraform destroy $JOINED_TERRAFORM_ARGS
