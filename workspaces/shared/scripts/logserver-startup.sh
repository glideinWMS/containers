#!/usr/bin/bash

# SPDX-FileCopyrightText: 2020 Fermi Research Alliance, LLC
# SPDX-License-Identifier: Apache-2.0

# Install, setup, and start on EL9 the GlideinWMS Logserver
# This assumes a GlideinWMS Factory is already installed


### INTRO ###

# Environment
OSG_REPO=
GWMS_REPO=osg-development
CHECK_ONLY=false
GWMS_USE_BUILD=false
# Outside mounted directory with shared files
GWMS_DIR=/opt/gwms

help(){
    cat <<EOF 
$0 [options]
Install the EL9 version of the GlideinWMS Logserver
--osg-repo OSG_REPO         Set the repository for the OSG osg-ca-certs, e.g. osg-development, osg (defaults to GWMS_REPO)
--gwms-repo GWMS_REPO       Set the GlideinWMS repository, e.g. osg-development (default), osg, upcoming-development
--check-only                Only print the available RPMs (no install and set up)
--use-build                 Use the build-workspace container as YUM repo
You cannot set both --factory and --frontend. If none is set the script tries to guess from the hostname
EOF
}

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
        --use-build)
            GWMS_USE_BUILD=true
            ;;
        --check-only)
            CHECK_ONLY=true
            ;;
        *)
            echo "Parameter '$1' is not supported."
            help
            exit 1
    esac
    shift
done

if [[ -z "$OSG_REPO" ]]; then
    OSG_REPO="$GWMS_REPO"
fi

if $GWMS_USE_BUILD; then
    # Install and setup the build server YUM repo
    if [[ ! -f /etc/yum.repos.d/build.repo ]]; then
        wget http://build-workspace.glideinwms.org/repo/build.repo -O /etc/yum.repos.d/build.repo
    fi
    GWMS_REPO="gwms-build"
fi


install(){    
    # Install the Logserver

    dnf install -y --enablerepo="$GWMS_REPO" glideinwms-logserver
}

check(){
    # Check if important installation steps worked OK
    
    if [[ ! -f /etc/php-fpm.conf ]]; then
        echo "php-fpm seems not installed. Aborting."
        exit 1
    fi
    if [[ ! -f /var/lib/gwms-logserver/composer.json ]]; then
        echo "php dependencies (composer configuration) not installed. Aborting."
        exit 1
    fi
}

setup(){
    # Setup
    
    echo "systemd_interval = 0" >> /etc/php-fpm.conf
    pushd /var/lib/gwms-logserver/
    if ! composer install; then
        # running a second time because the first frequently times out
        composer install
    fi
    popd

}
start(){
    # Start
    
    systemctl start php-fpm
    /sbin/service httpd reload > /dev/null 2>&1 || true
    systemctl enable httpd php-fpm
}


### MAIN ###


if $CHECK_ONLY; then
    echo "Listing available GlideinWMS Logserver packages and aborting"
    yum list --enablerepo="$GWMS_REPO" glideinwms-logserver
    exit 0
fi
install
check
setup
start
