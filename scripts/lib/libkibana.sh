#!/bin/bash

feed_kibana_encryption_keys() {
  if [ -f "$APP_HOME/../config/kibana/.encryption-key" ]; then
    echo "[::terraform] 🌱  Found X-Pack Encrypted Saved Objects Key in [$APP_HOME/config/kibana/.encryption-key]"
    export KIBANA_SAVEDOBJECTS_ENCRYPTIONKEY=$(< $APP_HOME/../config/kibana/.encryption-key)
  else
    echo "[::terraform] 🌱  Creating X-Pack Encrypted Saved Objects encryption key..."
    KEY=$(openssl rand -base64 48)

    touch "$APP_HOME/../config/kibana/.encryption-key"
    echo "$KEY" >> "$APP_HOME/../config/kibana/.encryption-key"
    export KIBANA_SAVEDOBJECTS_ENCRYPTIONKEY=$(< $APP_HOME/../config/kibana/.encryption-key)
  fi

  if [ -f "$APP_HOME/../config/kibana/.security-encryption-key" ]; then
    echo "[::terraform] 🌱  Found X-Pack Security Encryption Key in [$APP_HOME/config/kibana/.security-encryption-key]"
    export KIBANA_SECURITY_ENCRYPTIONKEY=$(< $APP_HOME/../config/kibana/.security-encryption-key)
  else
    echo "[::terraform] 🌱  Creating X-Pack Security encryption key..."
    KEY=$(openssl rand -base64 48)

    touch "$APP_HOME/../config/kibana/.security-encryption-key"
    echo "$KEY" >> "$APP_HOME/../config/kibana/.security-encryption-key"
    export KIBANA_SECURITY_ENCRYPTIONKEY=$(< $APP_HOME/../config/kibana/.security-encryption-key)
  fi

  if [ -f "$APP_HOME/../config/kibana/.reporting-encryption-key" ]; then
    echo "[::terraform] 🌱  Found X-Pack Reporting Encryption Key in [$APP_HOME/config/kibana/.reporting-encryption-key]"
    export KIBANA_REPORTING_ENCRYPTIONKEY=$(< $APP_HOME/../config/kibana/.reporting-encryption-key)
  else
    echo "[::terraform] 🌱  Creating X-Pack Reporting encryption key..."
    KEY=$(openssl rand -base64 48)

    touch "$APP_HOME/../config/kibana/.reporting-encryption-key"
    echo "$KEY" >> "$APP_HOME/../config/kibana/.reporting-encryption-key"
    export KIBANA_REPORTING_ENCRYPTIONKEY=$(< $APP_HOME/../config/kibana/.reporting-encryption-key)
  fi

  if [ -f "$APP_HOME/../config/kibana/.service-token" ]; then
    echo "[::terraform] 🌱  Found service token in [$APP_HOME/config/kibana/.service-token]"
    export KIBANA_SERVICE_TOKEN=$(< $APP_HOME/../config/kibana/.service-token)
  fi
}
