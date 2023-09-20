#!/bin/bash

# SPDX-FileCopyrightText: 2020 Fermi Research Alliance, LLC
# SPDX-License-Identifier: Apache-2.0

GWMS_DIR=/opt/gwms
REFRESH_ONLY=
[[ "$1" = refresh ]] && REFRESH_ONLY=true || true

if [[ -z "$REFRESH_ONLY" ]]; then
    # Just the first time
    bash /root/scripts/create-host-certificate.sh -d "$GWMS_DIR"/secrets
    bash /root/scripts/link-git.sh -a -p 3.9 -d "$GWMS_DIR"
    bash /root/scripts/create-idtokens.sh -a
    systemctl start httpd
    systemctl start condor
else
    # Stop before refresh
    systemctl stop gwms-factory
    systemctl restart condor  # in case the configuration changes
fi
# All the times
gwms-factory upgrade
systemctl start gwms-factory
