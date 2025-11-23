#!/bin/bash

# SPDX-FileCopyrightText: 2020 Fermi Research Alliance, LLC
# SPDX-License-Identifier: Apache-2.0

GWMS_DIR=/opt/gwms

help_msg() {
    cat << EOF
$0 [options]
Set up the CE. Create the host certificate and start HTCondor and HTCondor-CE.
  -h       print this message
  -v       verbose mode
  -d DIR   Set GWMS_DIR (default $GWMS_DIR)
  -r       refresh only (only restart of services)
EOF
}

FULL_STARTUP=true

while getopts "hvd:r" option
do
  case "${option}"
    in
    h) help_msg; exit 0;;
    v) VERBOSE=yes;;
    d) GWMS_DIR="${OPTARG}";;
    r) FULL_STARTUP=false;;
    *) echo "ERROR: Invalid option"; help_msg; exit 1;;
  esac
done

if $FULL_STARTUP; then
    [[ -n "$VERBOSE" ]] && echo "Full startup" || true
    # Generate httpd self-signed host certificates
    bash /opt/scripts/create-host-certificate.sh -d "$GWMS_DIR"/secrets
    # Generate host keys for sshd if they are missing
    [[  -f /etc/ssh/ssh_host_rsa_key ]] || ssh-keygen -A
    # can check ssh configuration with: sshd -t
    # Add Frontend/DE scitokens support
    bash /opt/scripts/add-frontend-scitokens.sh
    systemctl start sshd
    systemctl start condor
    systemctl start condor-ce
else
    [[ -n "$VERBOSE" ]] && echo "Refresh only" || true
    systemctl restart sshd  # in case the configuration changes
    systemctl restart condor  # in case the configuration changes
    systemctl restart condor-ce  # in case the configuration changes
fi
