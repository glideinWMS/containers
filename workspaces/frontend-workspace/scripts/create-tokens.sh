#!/bin/bash

TOKEN_DIR=/var/lib/gwms-frontend/.condor/tokens.d

echo Creating IDTOKENS...
systemctl start condor
sleep 5
condor_token_create -id vofrontend_service@"$HOSTNAME" -key POOL > "$TOKEN_DIR"/frontend."$HOSTNAME".idtoken
systemctl stop condor
echo Generating SciToken...
htgettoken --minsecs=3580 -i fermilab -v -a htvaultprod.fnal.gov -o "$TOKEN_DIR"/"$HOSTNAME".scitoken
chown frontend:frontend "$TOKEN_DIR"/*frontend*
chmod 600 "$TOKEN_DIR"/*frontend*
ls -lah "$TOKEN_DIR"
