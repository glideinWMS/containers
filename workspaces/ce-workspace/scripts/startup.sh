#!/bin/bash

bash /root/scripts/create-host-certificate.sh

systemctl start condor
systemctl start condor-ce
