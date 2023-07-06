#!/bin/bash

bash /root/scripts/create-host-certificate.sh
bash /root/scripts/create-tokens.sh
bash /root/scripts/link-git.sh

gwms-factory upgrade

systemctl start httpd
systemctl start condor
systemctl start gwms-factory
