#!/bin/bash

./opt/GlideinWMS/scripts/create-host-certificate.sh
systemctl start condor
systemctl start condor-ce
