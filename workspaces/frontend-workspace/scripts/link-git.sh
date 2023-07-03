#!/bin/bash

mkdir -p /opt/GlideinWMS
if [ ! "$(ls -A /opt/GlideinWMS/glideinwms)" ]; then
    git clone https://github.com/glideinWMS/glideinwms.git /opt/GlideinWMS/glideinwms
fi
rm -rf /usr/lib/python3.9/site-packages/glideinwms
rm -rf /var/lib/gwms-frontend/creation
rm -rf /var/lib/gwms-frontend/web-base
ln -s /opt/GlideinWMS/glideinwms /usr/lib/python3.9/site-packages/glideinwms
ln -s /opt/GlideinWMS/glideinwms/creation /var/lib/gwms-frontend/creation
ln -s /opt/GlideinWMS/glideinwms/creation/web_base /var/lib/gwms-frontend/web-base

pushd /usr/sbin

for i in \
checkFrontend glideinFrontend stopFrontend
do
    rm -f ${i}
    ln -s /opt/GlideinWMS/glideinwms/frontend/${i}.py ${i}
done

for i in \
glideinFrontendElement.py manageFrontendDowntimes.py
do
    rm -f ${i}
    ln -s /opt/GlideinWMS/glideinwms/frontend/${i} ${i}
done

for i in \
reconfig_frontend
do
    rm -f ${i}
    ln -s /opt/GlideinWMS/glideinwms/creation/${i} ${i}
done

for i in \
glidecondor_createSecCol glidecondor_addDN glidecondor_createSecSched
do
    rm -f ${i}
    ln -s /opt/GlideinWMS/glideinwms/install/${i} ${i}
done

popd
pushd /usr/bin/

rm -f /usr/bin/glidein*

for i in \
glidein_cat glidein_gdb glidein_interactive glidein_ls glidein_ps \
glidein_status glidein_top
do
    ln -s /opt/GlideinWMS/glideinwms/tools/${i}.py ${i}
done

popd
