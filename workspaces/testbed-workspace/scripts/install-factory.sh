#!/usr/bin/env bash


### INTRO ###

# Environment
OSG_VERSION=24
OSG_REPO=osg
GWMS_REPO=osg-development

# Argument parser
while [ -n "$1" ];do
    case "$1" in
        --osg-repo)
            OSG_REPO="$2"
            shift
            ;;
        --gwms-repo)
            GWMS_REPO="$2"
            shift
            ;;
        --osg-version)
            OSG_VERSION="$2"
            shift
            ;;
        *)
            echo "Parameter '$1' is not supported."
            exit 1
    esac
    shift
done


### REPOSITORIES ###

# OSG Repo
dnf -y install "https://repo.osg-htc.org/osg/$OSG_VERSION-main/osg-$OSG_VERSION-main-el9-release-latest.rpm"


### INSTALLATION ###

# OSG
yum install -y osg-ca-certs --enablerepo="$OSG_REPO"

# Factory
dnf -y install glideinwms-factory --enablerepo="$GWMS_REPO"


### CONFIGURATION ###

# GlideinWMS Factory configuration
GWMS_CONFIG=/etc/gwms-factory/glideinWMS.xml
cp /opt/config/factory/glideinWMS.xml $GWMS_CONFIG
chown gfactory.gfactory $GWMS_CONFIG
echo Updated Factory configuration

# HTCondor configuration
cp /opt/config/99-debug.conf /etc/condor/config.d
cp /opt/config/99-cafile.conf /etc/condor/config.d

# Condor tarball
CONDOR_TARBALL_URLS="
https://research.cs.wisc.edu/htcondor/tarball/10/10.x/10.6.0/release/condor-10.6.0-$(arch)_AlmaLinux9-stripped.tar.gz
https://research.cs.wisc.edu/htcondor/tarball/9.0/9.0.18/release/condor-9.0.18-x86_64_CentOS7-stripped.tar.gz
"
CONDOR_TARBALL_PATH=/var/lib/gwms-factory/condor
[ ! -d $CONDOR_TARBALL_PATH ] && mkdir -p $CONDOR_TARBALL_PATH
pushd $CONDOR_TARBALL_PATH || exit 3
for CONDOR_TARBALL_URL in $CONDOR_TARBALL_URLS; do
    wget "$CONDOR_TARBALL_URL"
    CONDOR_TARBALL=$(echo "$CONDOR_TARBALL_URL" | awk -F'/' '{print $NF}')
    tar -xf "$CONDOR_TARBALL"
done
popd || exit 4


### STARTUP ###

GWMS_DIR=/opt/gwms
bash /opt/scripts/create-host-certificate.sh -d "$GWMS_DIR"/secrets
bash /opt/scripts/create-idtokens.sh -a
systemctl start httpd
systemctl start condor
gwms-factory upgrade
systemctl start gwms-factory
