#!/bin/bash

# SPDX-FileCopyrightText: 2020 Fermi Research Alliance, LLC
# SPDX-License-Identifier: Apache-2.0

help_msg() {
    cat << EOF
$0 [options] 
  -h       print this message
  -v       verbose mode
  -a       set up fActory
  -r       set up fRontend
EOF
}

while getopts "harv" option
do
  case "${option}"
    in
    h) help_msg; exit 0;;
    v) VERBOSE=yes;;
    a) IS_FACTORY=yes;;
    r) IS_FRONTEND=yes;;
    *) echo "ERROR: wrokg option"; help_msg; exit 1;;
  esac
done

echo Creating IDTOKENS...
# Without -lifetime, idtokens have no lifetime restrictions
condor_store_cred add -c -p $HOSTNAME.$RANDOM
if [[ -n "$IS_FACTORY" ]]; then
    TOKEN_DIR=/var/lib/gwms-factory/.condor/tokens.d
    condor_token_create -id vofrontend_service@"$HOSTNAME" -key POOL > "$TOKEN_DIR"/frontend."$HOSTNAME".idtoken
    condor_token_create -id gfactory@"$HOSTNAME" > "$TOKEN_DIR"/gfactory."$HOSTNAME".idtoken
    chown gfactory:gfactory "$TOKEN_DIR"/gfactory.*
    chmod 600 "$TOKEN_DIR"/gfactory.*
    # TODO: check is the frontend.* token hsould have different owner/permission
fi
if [[ -n "$IS_FRONTEND" ]]; then
    TOKEN_DIR=/var/lib/gwms-frontend/.condor/tokens.d
    condor_token_create -id vofrontend_service@"$HOSTNAME" -key POOL > "$TOKEN_DIR"/frontend."$HOSTNAME".idtoken
    chown frontend:frontend "$TOKEN_DIR"/frontend.*
    chmod 600 "$TOKEN_DIR"/frontend.*
fi
ls -lah "$TOKEN_DIR"
