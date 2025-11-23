#!/usr/bin/bash

# SPDX-FileCopyrightText: 2020 Fermi Research Alliance, LLC
# SPDX-License-Identifier: Apache-2.0

# Install development software
# Used to minimize the software installed in the base image (testbed-workspace)

if [[ "$1" = "-h" || "$1" = "--help" ]]; then
    cat <<EOF
$0 [options]
Install some development software and GWMS aliases
Options:
 -h|--help   print this message and exit
EOF
    exit 0
fi

# Development tools
# Removed yq (not available in regular RPM repos, go install github.com/mikefarah/yq/v4@latest - requires go 1.24)
dnf config-manager --add-repo https://cli.github.com/packages/rpm/gh-cli.repo
dnf install -y yum python3 python3-pip git gh bc jq jc vim zsh sudo psmisc bind-utils mlocate

# Deploy GWMS aliases
/usr/bin/wget -O ~/.bash_aliases https://raw.githubusercontent.com/glideinWMS/dev-tools/master/.bash_aliases && \
    . ~/.bash_aliases || true
