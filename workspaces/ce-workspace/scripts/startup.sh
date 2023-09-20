#!/bin/bash

# SPDX-FileCopyrightText: 2020 Fermi Research Alliance, LLC
# SPDX-License-Identifier: Apache-2.0

GWMS_DIR=/opt/gwms

bash /root/scripts/create-host-certificate.sh -d "$GWMS_DIR"/secrets

systemctl start condor
systemctl start condor-ce
