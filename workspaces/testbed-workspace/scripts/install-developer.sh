#!/usr/bin/bash

# SPDX-FileCopyrightText: 2020 Fermi Research Alliance, LLC
# SPDX-License-Identifier: Apache-2.0

# Install development software
# Used to minimize the software installed in the base image (testbed-workspace)

# Development tools
dnf install -y python3 wget git jq vim zsh sudo psmisc bind-utils mlocate

# Deploy GWMS aliases
/usr/bin/wget -O ~/.bash_aliases https://raw.githubusercontent.com/glideinWMS/dev-tools/master/.bash_aliases && \
    . ~/.bash_aliases || true
