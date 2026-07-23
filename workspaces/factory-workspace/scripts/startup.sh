#!/bin/bash

# SPDX-FileCopyrightText: 2020 Fermi Research Alliance, LLC
# SPDX-License-Identifier: Apache-2.0

GWMS_DIR=/opt/gwms
FULL_STARTUP=true
DO_LINK_GIT=
GWMS_REPO=
# Leaving unchanged. Default branch after cloning is master
GWMS_REPO_REF=
BOSCO_HOST=
FACT_USER=gfactory
SECRETS_DIR=


help_msg() {
    cat << EOF
$0 [options] 
  -h       print this message
  -v       verbose mode
  -b HOST  setup BOSCO (condor_remote_host) to HOST (Default: bosco@ce-workspace.glideinwms.org/condor)
  -g       do Git setup (default for regular startup)
  -G       skip Git setup (default for refresh)
  -d DIR   Set GWMS_DIR (default $GWMS_DIR)
  -c REF   Checkout REF in the GlideinWMS Git repository (Default: no checkout, leave the default/existing reference)
  -u URL   Git repository URL (See link-git.sh for Default)
  -s DIR   Set the secrets dir for BOSCO and host keys (Default: GWMS_DIR/secrets)
  -r       refresh only
EOF
}

while getopts "hvb:gGd:c:u:s:r" option
do
  case "${option}"
    in
    h) help_msg; exit 0;;
    v) VERBOSE=yes;;
    b) BOSCO_HOST="${OPTARG}";;
    g) DO_LINK_GIT=true;;
    G) DO_LINK_GIT=false;;
    d) GWMS_DIR="${OPTARG}";;
    c) GWMS_REPO_REF="-c ${OPTARG}";;
    u) GWMS_REPO="-u ${OPTARG}";;
    r) FULL_STARTUP=false;;
    s) SECRETS_DIR="${OPTARG}";;
    *) echo "ERROR: Invalid option"; help_msg; exit 1;;
  esac
done

[[ -z "$SECRETS_DIR" ]] && SECRETS_DIR="$GWMS_DIR"/secrets || true
[[ -z "$DO_LINK_GIT" ]] && DO_LINK_GIT=$FULL_STARTUP || true
KEY_FILE_SRC="$SECRETS_DIR/boscokey"

bosco_setup() {
    # Copy the public key to the authorized ones
    FACT_HOME=$(getent passwd "$FACT_USER" | cut -d: -f6 )
    if [[ -z "$FACT_HOME" ]]; then
        echo "Factory user ($FACT_USER) is missing. Aborting BOSCO setup."
        return 1
    fi
    if [[ ! -d "$FACT_HOME/.ssh" ]]; then
        mkdir -p "$FACT_HOME/.ssh"
        chmod 700 "$FACT_HOME/.ssh"
        chown "$FACT_USER": "$FACT_HOME/.ssh"
    fi
    cp "$KEY_FILE_SRC"  "$FACT_HOME"/.ssh/
    local key_file_path
    key_file_path="$FACT_HOME/.ssh/$(basename "$KEY_FILE_SRC")"
    chmod 600 "$key_file_path"
    [[ -n "$VERBOSE" ]] && echo "BOSCO Key added to the Factory user ($FACT_USER)." || true 
    [[ -n "$VERBOSE" ]] && echo "Making sure the Factory can connect to the CE host" || true
    cat << EOF >> "$FACT_HOME/.ssh/config"
# Policies to allow SSH for HTCondor Remote Cluster (BOSCO)
# PubkeyAuthentication yes

Host *.glideinwms.org
        StrictHostKeyChecking accept-new
EOF
    chown "$FACT_USER": "$FACT_HOME"/.ssh/*
    # done or run condor_remote_cluster?
    /opt/scripts/condor_remote_cluster ${VERBOSE:+-d} -a $BOSCO_HOST htcondor
}


if $FULL_STARTUP; then
    # Just the first time
    [[ -n "$VERBOSE" ]] && echo "Full startup" || true
    bash /opt/scripts/create-host-certificate.sh -d "$SECRETS_DIR"
    # shellcheck disable=SC2086   # Options are unquoted to allow globbing
    $DO_LINK_GIT && bash /opt/scripts/link-git.sh -a -d "$GWMS_DIR" $GWMS_REPO $GWMS_REPO_REF || true
    bash /opt/scripts/create-idtokens.sh -a
    # BOSCO
    [[ -n "$BOSCO_HOST" ]] && bosco_setup || true
    systemctl start httpd
    # PHP may be used by the logserver
    if [[ -f /etc/php-fpm.conf ]]; then
        # the container systemd imitation cannot receive messages
        echo "systemd_interval = 0" >> /etc/php-fpm.conf
        systemctl start php-fpm
        if [[ -f /var/lib/gwms-logserver/composer.json ]]; then
            pushd /var/lib/gwms-logserver/
            if ! composer install; then
                # running a second time because the first frequently times out
                composer install
            fi
            popd
        fi
    fi
    systemctl start condor
else
    # Stop before refresh
    [[ -n "$VERBOSE" ]] && echo "Refresh only" || true
    systemctl stop gwms-factory
    # shellcheck disable=SC2086   # Options are unquoted to allow globbing
    $DO_LINK_GIT && bash /opt/scripts/link-git.sh -a -d "$GWMS_DIR" $GWMS_REPO $GWMS_REPO_REF || true
    systemctl restart condor  # in case the configuration changes
fi
# All the times
gwms-factory upgrade
systemctl start gwms-factory
