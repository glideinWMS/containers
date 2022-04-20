#!/bin/bash

cp /etc/gwms-frontend/frontend.xml.base /etc/gwms-frontend/frontend.xml 
chown frontend /etc/gwms-frontend/frontend.xml

# Make 'frontend' the owner of the default tokens directory
if [ -e /home/frontend/.condor/tokens.d ]; then
   chown frontend:frontend -R /home/frontend/.condor/tokens.d
   chmod -R 0600 /home/frontend/.condor
fi
