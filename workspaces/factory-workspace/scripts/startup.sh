#!/bin/bash

# SPDX-FileCopyrightText: 2020 Fermi Research Alliance, LLC
# SPDX-License-Identifier: Apache-2.0

GWMS_DIR=/opt/gwms
FULL_STARTUP=true
DO_LINK_GIT=
GWMS_REPO=
# Leaving unchanged. Default branch after cloning is master
GWMS_REPO_REF=

help_msg() {
    cat << EOF
$0 [options] 
  -h       print this message
  -v       verbose mode
  -g       do Git setup (default for regular startup)
  -G       skip Git setup (default for refresh)
  -d DIR   Set GWMS_DIR (default $GWMS_DIR)
  -c REF   Checkout REF in the GlideinWMS Git repository (Default: no checkout, leave the default/existing reference)
  -u URL   Git repository URL (See link-git.sh for Default)
  -r       refresh only
EOF
}

while getopts "hvgGd:c:u:r" option
do
  case "${option}"
    in
    h) help_msg; exit 0;;
    v) VERBOSE=yes;;
    g) DO_LINK_GIT=true;;
    G) DO_LINK_GIT=false;;
    d) GWMS_DIR="${OPTARG}";;
    c) GWMS_REPO_REF="-c ${OPTARG}";;
    u) GWMS_REPO="-u ${OPTARG}";;
    r) FULL_STARTUP=false;;
    *) echo "ERROR: Invalid option"; help_msg; exit 1;;
  esac
done

[[ -z "$DO_LINK_GIT" ]] && DO_LINK_GIT=$FULL_STARTUP || true

if $FULL_STARTUP; then
    # Just the first time
    [[ -n "$VERBOSE" ]] && echo "Full startup" || true
    bash /opt/scripts/create-host-certificate.sh -d "$GWMS_DIR"/secrets
    # shellcheck disable=SC2086   # Options are unquoted to allow globbing
    $DO_LINK_GIT && bash /opt/scripts/link-git.sh -a -d "$GWMS_DIR" $GWMS_REPO $GWMS_REPO_REF || true
    bash /opt/scripts/create-idtokens.sh -a
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
