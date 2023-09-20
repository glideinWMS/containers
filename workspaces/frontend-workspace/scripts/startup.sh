#!/bin/bash

# SPDX-FileCopyrightText: 2020 Fermi Research Alliance, LLC
# SPDX-License-Identifier: Apache-2.0

GWMS_DIR=/opt/gwms
REFRESH_ONLY=
[[ "$1" = refresh ]] && REFRESH_ONLY=true || true

if [[ -z "$REFRESH_ONLY" ]]; then
    # First time only
    bash /root/scripts/create-host-certificate.sh -d "$GWMS_DIR"/secrets
    bash /root/scripts/link-git.sh -r -p 3.9 -d "$GWMS_DIR"
    bash /root/scripts/create-idtokens.sh -r
    systemctl start httpd
    systemctl start condor
else
    # Other times only (refresh) 
    systemctl stop gwms-frontend
    systemctl restart condor  # in case the configuration changes
fi
# All the times
# Always recreate the scitoken (expires quickly, OK to have a new one)
bash /root/scripts/create-scitoken.sh
gwms-frontend upgrade
systemctl start gwms-frontend
