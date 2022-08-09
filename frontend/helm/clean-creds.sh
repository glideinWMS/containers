#!/bin/sh
# util script to clear automatically generated passwords and tokens for debugging
rm persistent-mount/condor/passwords.d/POOL persistent-mount/condor/passwords.d/FRONTEND \
    persistent-mount/condor/tokens.d/condor.idtoken \
    persistent-mount/frontend/passwords.d/FRONTEND \
    persistent-mount/frontend/tokens.d/frontend.$HOSTNAME.idtoken \
