#!/bin/bash

# SPDX-FileCopyrightText: 2020 Fermi Research Alliance, LLC
# SPDX-License-Identifier: Apache-2.0

help_msg() {
    cat << EOF
$0 [options]
Generate multiple idtokens for each of the selected servers
  -h       print this message
  -v       verbose mode
  -a       set up fActory server
  -r       set up fRontend server
  -e       set up dEcision Engine server
EOF
}

# Defaults
VERBOSE=
IS_FACTORY=
IS_FRONTEND=
IS_DE=
        
while getopts "harev" option
do
  case "${option}"
    in
    h) help_msg; exit 0;;
    v) VERBOSE=yes;;
    a) IS_FACTORY=yes;;
    r) IS_FRONTEND=yes;;
    e) IS_DE=yes;;
    *) echo "ERROR: wrong option"; help_msg; exit 1;;
  esac
done

echo Creating IDTOKENS for host $HOSTNAME ...
# Without -lifetime, idtokens have no lifetime restrictions (i.e. no expiration)
# Depending on the consor version `condor_store_cred add-pwd -c -p "$HOSTNAME".$RANDOM` or `condor_store_cred add -c -p "$HOSTNAME".$RANDOM`
if ! condor_store_cred add -c -p "$HOSTNAME".$RANDOM; then
    echo "WARNING: condor_store_cred failed"
fi
[[ -n "$IS_FACTORY" || -n "$IS_FRONTEND" || -n "$IS_DE" ]] || echo "WARNING: This host is not identified as Factory, nor Frontend, nor Decision Engine."
if [[ -n "$IS_FACTORY" ]]; then
    TOKEN_DIR=/var/lib/gwms-factory/.condor/tokens.d
    failed_command=false
    condor_token_create -id vofrontend_service@"$HOSTNAME" -key POOL > "$TOKEN_DIR"/frontend."$HOSTNAME".idtoken || failed_command=true
    condor_token_create -id gfactory@"$HOSTNAME" > "$TOKEN_DIR"/gfactory."$HOSTNAME".idtoken || failed_command=true
    if $failed_command; then
        echo "WARNING: condor_token_create failed"
    else
        chown gfactory:gfactory "$TOKEN_DIR"/gfactory.*
        chmod 600 "$TOKEN_DIR"/gfactory.*
    fi
    # TODO: check if the frontend.* token should have different owner/permission
    echo Factory:
    ls -lah "$TOKEN_DIR"
fi
if [[ -n "$IS_FRONTEND" ]]; then
    TOKEN_DIR=/var/lib/gwms-frontend/.condor/tokens.d
    if condor_token_create -id vofrontend_service@"$HOSTNAME" -key POOL > "$TOKEN_DIR"/frontend."$HOSTNAME".idtoken; then
        chown frontend:frontend "$TOKEN_DIR"/frontend.*
        chmod 600 "$TOKEN_DIR"/frontend.*
    else
        echo "WARNING: condor_token_create failed"
    fi
    echo Frontend:
    ls -lah "$TOKEN_DIR"
fi
if [[ -n "$IS_DE" ]]; then
    TOKEN_DIR=/var/lib/decisionengine/.condor/tokens.d
    if condor_token_create -id decisionengine_service@"$HOSTNAME" -key POOL > "$TOKEN_DIR"/decisionengine."$HOSTNAME".idtoken; then
        chown decisionengine:decisionengine "$TOKEN_DIR"/decisionengine.*
        chmod 600 "$TOKEN_DIR"/decisionengine.*
    else
        echo "WARNING: condor_token_create failed"
    fi
    echo Decision Engine:
    ls -lah "$TOKEN_DIR"
fi
