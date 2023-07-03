#!/bin/bash

mkdir -p /opt/GlideinWMS
if [ ! "$(ls -A /opt/GlideinWMS/glideinwms)" ]; then
    git clone https://github.com/glideinWMS/glideinwms.git /opt/GlideinWMS/glideinwms
fi
rm -rf /usr/lib/python3.9/site-packages/glideinwms
rm -rf /var/lib/gwms-factory/creation
rm -rf /var/lib/gwms-factory/web-base
ln -s /opt/GlideinWMS/glideinwms /usr/lib/python3.9/site-packages/glideinwms
ln -s /opt/GlideinWMS/glideinwms/creation /var/lib/gwms-factory/creation
ln -s /opt/GlideinWMS/glideinwms/creation/web_base /var/lib/gwms-factory/web-base

pushd /usr/sbin

for i in \
checkFactory.py glideFactoryEntryGroup.py glideFactoryEntry.py \
glideFactory.py manageFactoryDowntimes.py stopFactory.py
do
    rm -f ${i}*
    ln -s /opt/GlideinWMS/glideinwms/factory/${i} ${i}
    ln -s /opt/GlideinWMS/glideinwms/factory/${i}o ${i}o
    ln -s /opt/GlideinWMS/glideinwms/factory/${i}c ${i}c
done

for i in \
clone_glidein info_glidein reconfig_glidein
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
pushd /usr/bin

for i in \
glidein_cat glidein_gdb glidein_interactive glidein_ls glidein_ps \
glidein_status glidein_top
do
    rm -f ${i}
    ln -s /opt/GlideinWMS/glideinwms/tools/${i}.py ${i}
done

popd
