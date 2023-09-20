#!/bin/sh

# SPDX-FileCopyrightText: 2020 Fermi Research Alliance, LLC
# SPDX-License-Identifier: Apache-2.0

sudo -u testuser bash -c 'cd $HOME; condor_submit submitFile'
