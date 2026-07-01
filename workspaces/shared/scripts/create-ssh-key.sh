#!/bin/bash

# SPDX-FileCopyrightText: 2020 Fermi Research Alliance, LLC
# SPDX-License-Identifier: Apache-2.0

SECRETS_DIR=/opt/gwms/secrets
PASSPHRASE=""
BOSCOUSER=bosco

loginfo() {
    [[ -z "$VERBOSE" ]] || echo "$@"
}
    
help_msg() {
    cat << EOF
$0 [options]
Initialize a ssh key to use for HTCondor remote cluster (BOSCO)
  -h       print this message
  -v       verbose mode
  -f       force key re-creation even if it is already there
  -d DIR   secrets directory (default: $SECRETS_DIR)
  -u USER  Remote Cluster (BOSCO) user name (default: $BOSCOUSER)
  -p PASS  passphrase (default: $PASSPHRASE)
EOF
}
    
main() {
    while getopts "hvfd:u:p:" option
    do
      case "${option}"
        in
        h) help_msg; exit 0;;
        v) VERBOSE=yes;;
        f) FORCE=yes;;
        d) SECRETS_DIR=$OPTARG;;
        u) BOSCOUSER=$OPTARG;;
        p) PASSPHRASE=$OPTARG;;
        *) echo "Invalid option: ${option}"; help_msg; exit 1;;
      esac
    done
    
    # Set the file paths and details for the certificate
    KEY_FILE="$SECRETS_DIR/boscokey"
    PUBKEY_FILE="$SECRETS_DIR/boscokey.pub"
    COMMON_NAME="$HOSTNAME"
    VALIDITY_PERIOD=365
    
    # Removing old priv/pub keys if forcing re-creation
    if [[ -f "$KEY_FILE" ]]; then
        if [[ -n "$FORCE" ]]; then
            rm -f "$KEY_FILE" "$PUBKEY_FILE"
        else
            loginfo "Key '$KEY_FILE' already present. Skipping Remote Cluster (BOSCO) SSH key creation."
            exit 0
        fi
    fi
    
    # Creating ssh keys
    loginfo "Creating Remote Cluster (BOSCO) SSH key"
    mkdir -p "$SECRETS_DIR"
    # Creating RSA key. Change command to change size or type (-b 4096 -t rsa  or -t ed25519).
    if ! out=$(ssh-keygen -C "BOSCOce" -f "$KEY_FILE" -N "$PASSPHRASE"); then
        echo "Failed to create Remote Cluster (BOSCO) SSH key. Aborting."
        echo "$out"
        exit 1
    else
        loginfo "$out"
    fi
    
    # Copy the public key to the authorized ones
    BOSCO_HOME=$(getent passwd "$BOSCOUSER" | cut -d: -f6 )
    if [[ -z "$BOSCO_HOME" ]]; then
        echo "BOSCO user is missing. Aborting."
        exit 1
    fi
    if [[ ! -d "$BOSCO_HOME/.ssh" ]]; then
        mkdir -p "$BOSCO_HOME/.ssh"
        chmod 700 "$BOSCO_HOME/.ssh"
        chown "$BOSCOUSER": "$BOSCO_HOME/.ssh"
    fi
    cat "$PUBKEY_FILE" >> "$BOSCO_HOME/.ssh/authorized_keys"
    chown "$BOSCOUSER": "$BOSCO_HOME/.ssh/authorized_keys"
    chmod 600 "$BOSCO_HOME/.ssh/authorized_keys"
    loginfo "Key added to the BOSCO user ($BOSCOUSER)."
    
    loginfo "Making sure the host can accept PubKey"
    cat << EOF > /etc/ssh/sshd_config.d/60-bosco.conf
# Policies to allow SSH for HTCondor Remote Cluster (BOSCO)
PubkeyAuthentication yes

Host *.glideinwms.org
        StrictHostKeyChecking accept-new
EOF
    
    # Use: ssh -o StrictHostKeyChecking=accept-new user@hostname
    # to add the fingerprint to ~/.ssh/known_hosts
    # Or add to ~/.ssh/config
    #Host *
    #        StrictHostKeyChecking accept-new
    # Os add the following to ~/.ssh/known_hosts
    loginfo "Host key for known_hosts:"
    loginfo "$COMMON_NAME $(ssh-keyscan -H "$COMMON_NAME" 2>/dev/null | grep ssh-ed25519 | cut -d ' ' -f 2-)"
}

main
