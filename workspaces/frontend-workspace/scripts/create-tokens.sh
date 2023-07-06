#!/bin/bash

TOKEN_DIR=/var/lib/gwms-frontend/.condor/tokens.d

echo Creating IDTOKENS...
condor_store_cred -c add -p $RANDOM
condor_token_create -id vofrontend_service@"$HOSTNAME" -key POOL > "$TOKEN_DIR"/frontend."$HOSTNAME".idtoken
