#!/bin/bash

# SPDX-FileCopyrightText: 2020 Fermi Research Alliance, LLC
# SPDX-License-Identifier: Apache-2.0

TOKEN_DIR=/var/lib/gwms-frontend/.condor/tokens.d
TOKEN_OWNER="frontend"
TOKEN_SERVER="htvaultprod.fnal.gov"
TOKEN_VO=fermilab

help_msg() {
    cat << EOF
$0 [options] 
  -h       print this message
  -v       verbose mode
  -d DIR   HTCondor tokens directory (default: $TOKEN_DIR)
  -u USER  user owning the SciToken (default: $TOKEN_OWNER)
  -s SRV   SciToken server (default: $TOKEN_SERVER)
  -i VO    token VO (default: $TOKEN_VO)
EOF
}

while getopts "hd:u:s:i:v" option
do
  case "${option}"
    in
    h) help_msg; exit 0;;
    v) VERBOSE=yes;;
    d) TOKEN_DIR=$OPTARG;;
    u) TOKEN_OWNER=$OPTARG;;
    s) TOKEN_SERVER=$OPTARG;;
    i) TOKEN_VO=$OPTARG;;
    *) echo "ERROR: wrokg option"; help_msg; exit 1;;
  esac
done

echo Generating SciToken...
htgettoken --minsecs=3580 -i "$TOKEN_VO" -v -a "$TOKEN_SERVER" -o "$TOKEN_DIR"/"$HOSTNAME".scitoken
chown "$TOKEN_OWNER": "$TOKEN_DIR"/"$HOSTNAME".scitoken
chmod 600 "$TOKEN_DIR"/"$HOSTNAME".scitoken
ls -lah "$TOKEN_DIR"
