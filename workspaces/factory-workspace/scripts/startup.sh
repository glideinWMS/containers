#!/bin/bash

# SPDX-FileCopyrightText: 2020 Fermi Research Alliance, LLC
# SPDX-License-Identifier: Apache-2.0

GWMS_DIR=/opt/gwms
FULL_STARTUP=true
DO_LINK_GIT=

help_msg() {
    cat << EOF
$0 [options] 
  -h       print this message
  -v       verbose mode
  -g       do Git setup (default for regular startup)
  -G       skip Git setup (default for refresh)
  -r       refresh only
EOF
}

while getopts "hvgGr" option
do
  case "${option}"
    in
    h) help_msg; exit 0;;
    v) VERBOSE=yes;;
    g) DO_LINK_GIT=true;;
    G) DO_LINK_GIT=false;;
    r) FULL_STARTUP=false;;
    *) echo "ERROR: Invalid option"; help_msg; exit 1;;
  esac
done

[[ -z "$DO_LINK_GIT" ]] && DO_LINK_GIT=$FULL_STARTUP || true

if $FULL_STARTUP; then
    # Just the first time
    [[ -n "$VERBOSE" ]] && echo "Full startup" || true
    bash /root/scripts/create-host-certificate.sh -d "$GWMS_DIR"/secrets
    $DO_LINK_GIT && bash /root/scripts/link-git.sh -a -p 3.9 -d "$GWMS_DIR"
    bash /root/scripts/create-idtokens.sh -a
    systemctl start httpd
    systemctl start condor
else
    # Stop before refresh
    [[ -n "$VERBOSE" ]] && echo "Refresh only" || true
    systemctl stop gwms-factory
    $DO_LINK_GIT && bash /root/scripts/link-git.sh -a -p 3.9 -d "$GWMS_DIR"
    systemctl restart condor  # in case the configuration changes
fi
# All the times
gwms-factory upgrade
systemctl start gwms-factory
