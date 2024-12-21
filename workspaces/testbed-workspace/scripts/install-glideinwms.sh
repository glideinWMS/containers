#!/usr/bin/bash

# SPDX-FileCopyrightText: 2020 Fermi Research Alliance, LLC
# SPDX-License-Identifier: Apache-2.0

# Install on EL9 the GlideinWMS software from a specific repository


### INTRO ###

# Environment
OSG_VERSION=24
OSG_REPO=
GWMS_REPO=osg-development
GWMS_SW=
CHECK_ONLY=false
GWMS_USE_BUILD=false
# Outside mounted directory with shared files
GWMS_DIR=/opt/gwms

help(){
    cat <<EOF 
$0 [options]
Install the EL9 version of the specified GlideinWMS software
--osg-repo OSG_REPO         Set the repository for the OSG osg-ca-certs, e.g. osg-development, osg (defaults to GWMS_REPO)
--gwms-repo GWMS_REPO       Set the GlideinWMS repository, e.g. osg-development (default), osg, upcoming-development
--osg-version OSG_VERSION   Set the OSG version, e.g. 24 (default), 23
--factory                   Install the Factory
--frontend                  Install the Frontend
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
        --osg-version)
            OSG_VERSION="$2"
            shift
            ;;
        --use-build)
            GWMS_USE_BUILD=true
            ;;
        --check-only)
            CHECK_ONLY=true
            ;;
        --factory)
            GWMS_SW=factory
            ;;
        --frontend)
            GWMS_SW=vofrontend
            ;;
        *)
            echo "Parameter '$1' is not supported."
            help
            exit 1
    esac
    shift
done

if [[ -z "$GWMS_SW" ]]; then
    myhost=$(hostname)
    if [[ "$myhost" = *factory* ]]; then
        GWMS_SW=factory
    elif [[ "$myhost" = *frontend* ]]; then
        GWMS_SW=vofrontend
    else
        echo "Unable to determine what to install"
        help
        exit 1
    fi
fi

if [[ -z "$OSG_REPO" ]]; then
    OSG_REPO="$GWMS_REPO"
fi

if $GWMS_USE_BUILD; then
    wget http://build-workspace.glideinwms.org/repo/build.repo -O /etc/yum.repos.d/build.repo
    GWMS_REPO="gwms-build"
fi


### INSTALLATION ###

install_pre(){
    # Install the OSG repository
    
    # OSG Repo
    dnf -y install "https://repo.osg-htc.org/osg/$OSG_VERSION-main/osg-$OSG_VERSION-main-el9-release-latest.rpm"
}

install_sw(){    
    # Install common OSG packages, and the GlideinWMS software

    # OSG packages
    dnf install -y --enablerepo="$OSG_REPO" osg-ca-certs htgettoken  

    # Install the GlideinWMS Factory/Frontend
    dnf install -y --enablerepo="$GWMS_REPO" glideinwms-$GWMS_SW
    if [[ "$GWMS_SW" = vofrontend ]]; then
        # sudo is required by the run-test script
        dnf install -y sudo
    fi
}


### CONFIGURATION ###

configure_common(){
    # HTCondor configuration
    cp /opt/config/99-debug.conf /etc/condor/config.d
    cp /opt/config/99-cafile.conf /etc/condor/config.d
}

configure_factory(){
    # GlideinWMS Factory configuration
    GWMS_CONFIG=/etc/gwms-factory/glideinWMS.xml
    cp /opt/config/factory/glideinWMS.xml $GWMS_CONFIG
    chown gfactory.gfactory $GWMS_CONFIG
    echo Updated Factory configuration
        
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
}

configure_frontend(){
    # GlideinWMS Frontend configuration
    GWMS_CONFIG=/etc/gwms-frontend/frontend.xml
    cp /opt/config/frontend/frontend.xml $GWMS_CONFIG
    chown frontend.frontend $GWMS_CONFIG
    echo Updated Frontend configuration
}


### STARTUP ###

start_common(){
    bash /opt/scripts/create-host-certificate.sh -d "$GWMS_DIR"/secrets
    systemctl start httpd
    systemctl start condor    
}

start_logserver(){
    # Will start only if installed
    if [[ -f /etc/php-fpm.conf ]]; then
        systemctl start start php-fpm
        echo "systemd_interval = 0" >> /etc/php-fpm.conf
        if [[ -f /var/lib/gwms-logserver/composer.json ]]; then
            pushd /var/lib/gwms-logserver/
            if ! composer install; then
                # running a second time because the first frequently times out
                composer install
            fi
            popd
        fi
    fi
}

start_factory(){
    bash /opt/scripts/create-idtokens.sh -a
    gwms-factory upgrade
    systemctl start gwms-factory
}

start_frontend(){
    bash /opt/scripts/create-idtokens.sh -r
    bash /opt/scripts/create-scitoken.sh
    gwms-frontend upgrade
    systemctl start gwms-frontend
}


### MAIN ###

install_pre
if $CHECK_ONLY; then
    echo "Listing available GlideinWMS packages and aborting"
    yum list --enablerepo="$GWMS_REPO" glideinwms\*
    exit 0
fi
install_sw
configure_common
if [[ "$GWMS_SW" = factory ]]; then
    configure_factory
else
    configure_frontend
fi
start_common
start_logserver
if [[ "$GWMS_SW" = factory ]]; then
    start_factory
else
    start_frontend
fi
