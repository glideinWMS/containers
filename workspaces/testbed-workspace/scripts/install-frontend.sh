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

# Frontend
dnf -y install glideinwms-vofrontend --enablerepo="$GWMS_REPO"


### CONFIGURATION ###

# GlideinWMS Frontend configuration
GWMS_CONFIG=/etc/gwms-frontend/frontend.xml
cp /opt/config/frontend/frontend.xml $GWMS_CONFIG
chown frontend.frontend $GWMS_CONFIG
echo Updated Frontend configuration

# HTCondor configuration
cp /opt/config/99-debug.conf /etc/condor/config.d
cp /opt/config/99-cafile.conf /etc/condor/config.d


### STARTUP ###

GWMS_DIR=/opt/gwms
bash /opt/scripts/create-host-certificate.sh -d "$GWMS_DIR"/secrets
bash /opt/scripts/create-idtokens.sh -r
bash /opt/scripts/create-scitoken.sh
systemctl start httpd
systemctl start condor
gwms-frontend upgrade
systemctl start gwms-frontend
