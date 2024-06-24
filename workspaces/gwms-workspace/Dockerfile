# SPDX-FileCopyrightText: 2020 Fermi Research Alliance, LLC
# SPDX-License-Identifier: Apache-2.0

# Selecting AlmaLinux 9 as the base OS
FROM almalinux:9
ARG TARGETPLATFORM
ARG BUILDPLATFORM
ARG BUILD_VERSION=dev
ARG BUILD_REF
ARG BUILD_HASH
ARG BUILD_SHA
ARG BUILD_DATE
# MAINTAINER is deprecated but it is needed to set Author in the image attributes
MAINTAINER GlideinWMS Team <glideinwms@fnal.gov>
LABEL name="Base workspace with EL9, OSG 3.6 and base packages required by GlideinWMS and HEPCloud" \
      org.opencontainers.image.authors="GlideinWMS Team glideinwms@fnal.gov" \
      org.opencontainers.image.title="GWMS Base Workspace" \
      org.opencontainers.image.description="Base workspace with EL9, OSG 3.6 and base packages required by GlideinWMS and HEPCloud" \
      org.opencontainers.image.url="https://glideinwms.fnal.gov/" \
      org.opencontainers.image.documentation="https://glideinwms.fnal.gov/" \
      org.opencontainers.image.source="https://github.com/glideinWMS/containers/tree/main/workspaces" \
      org.opencontainers.image.vendor="The GlideinWMS Team" \
      org.opencontainers.image.licenses="Apache-2.0" \
      org.opencontainers.image.revision="$BUILD_HASH" \
      org.opencontainers.image.ref.name="$BUILD_REF" \
      org.opencontainers.image.created="$BUILD_DATE"

RUN echo "Building GWMS base dev image ($BUILD_SHA/$BUILD_DATE) on $BUILDPLATFORM, for $TARGETPLATFORM"

# Installing some base packages, the CRB repo, needed by swig, and the EPEL (epel-release) and OSG repos
# Not installing epel-next-release, consider it for the future
# Not installing the HTCondor Madison repo (getting condor from OSG). In case needed (x509 is in HTCSS 9.0.x from HTCondor)
#    /usr/bin/wget http://research.cs.wisc.edu/htcondor/yum/repo.d/htcondor-stable-rhel9.repo -O /etc/yum.repos.d/condor.repo ;\
#    /usr/bin/wget http://research.cs.wisc.edu/htcondor/yum/RPM-GPG-KEY-HTCondor -O /etc/pki/rpm-gpg/RPM-GPG-KEY-HTCondor ;\
#    echo "priority=90" >> /etc/yum.repos.d/condor.repo ;\
#    echo "exclude=*.i686" >> /etc/yum.repos.d/condor.repo ;\
#    echo "gpgkey=file:///etc/pki/rpm-gpg/RPM-GPG-KEY-HTCondor" >> /etc/yum.repos.d/condor.repo
#    echo "exclude=*condor*" >> /etc/yum.repos.d/osg.repo
# Assigning the epel repo prio of 99 to make sure it is after the OSG one (98 by default)
# Installing wget to help with repo setup
RUN dnf install -y epel-release wget sed git yum-utils \
    https://repo.opensciencegrid.org/osg/3.6/osg-3.6-el9-release-latest.rpm && \
    dnf config-manager --set-enabled crb && \
    /bin/sed -i '/^enabled=1/a priority=99' /etc/yum.repos.d/epel.repo && \
    sed -i 's/\$basearch/x86_64/g' /etc/yum.repos.d/osg*
    # TODO: remove the sed command above when OSG supports aarch64

# Installing some system management RPMs/sw needed for containers (these are not needed for VMs)
RUN dnf install -y cronie supervisor initscripts ;\
    /usr/bin/wget https://raw.githubusercontent.com/gdraheim/docker-systemctl-replacement/master/files/docker/systemctl3.py -O /usr/local/bin/systemctl ;\
    /usr/bin/chmod +x /usr/local/bin/systemctl

# Installing some base RPMs (gettext is needed by RELEASE, swig and many devel by jsonnet)
# Install development tools
RUN dnf config-manager --add-repo https://cli.github.com/packages/rpm/gh-cli.repo && \
    dnf install -y python3 python3-devel python3-cryptography python3-wheel make openssl-devel gcc gcc-c++ rpm-build gettext swig \
    gh jq vim zsh sudo psmisc bind-utils mlocate ;\
    pip3 install debugpy ;

# Packages useful for development and administration
# Common packages for all GlideinWMS/HEPCloud software
RUN dnf -y install apptainer python3-rrdtool osg-ca-certs ;\
    /usr/bin/wget -O ~/.bash_aliases https://raw.githubusercontent.com/glideinWMS/dev-tools/master/.bash_aliases

# Installing HTCondor
# NOTE: OSG repos do not provide noarch HTCondor RPMs. Using https://get.htcondor.org
RUN curl -fsSL https://get.htcondor.org | /bin/bash -s -- --no-dry-run

# Installing htgettoken from source
# NOTE: htgettoken is not available in OSG 3.6 for EL9
RUN dnf -y install krb5-devel ;\
    git clone https://github.com/fermitools/htgettoken.git /opt/htgettoken && \
    pip install /opt/htgettoken/
    
# osg-wn-client already installed and osg-ca-certs is a dependency. Should CRLs (.r0) be removed?
#RUN yum -y install osg-ca-certs osg-wn-client \
#    && rm -f /etc/grid-security/certificates/*.r0

# Postponing dnf/yum/pip cleaning to later, to leave caches for next steps
# This must be after all dnf/yum and pip commands
# Cleaning YUM and DNF all caches (including disabled repos) and pip caches to reduce size of image
# RUN rm -rf /var/cache/yum/* /var/cache/dnf/* /root/.cache/pip/*

# Adding unprivileged user
RUN adduser abc ;\
    mkdir /home/abc/repos && \
    chown abc: /home/abc/repos ;\
    mkdir /opt/abc && \
    chown abc: /opt/abc

# Deploy secrets
COPY gwms-workspace/secrets /opt/localgwms/secrets


# Should ssh be enabled/installed?
# SSH config needs to be added
#ADD shared/ssh_config /etc/ssh/ssh_config

# GWMS and OSG suggested mount points
RUN mkdir -p /opt/gwms ; \
    for MNTPOINT in \
        /cvmfs \
        /hadoop \
        /hdfs \
        /lizard \
        /mnt/hadoop \
        /mnt/hdfs \
        /xenon \
        /scratch \
        /spt \
        /stash2 \
    ; do \
        mkdir -p $MNTPOINT ; \
    done

# Default entry point
CMD ["/bin/bash"]

# Optional health check (startup will add health check after setup completes)
#HEALTHCHECK --interval=5m CMD [ ! -f /healthcheck.sh ] && exit 0 || ./healthcheck.sh

# build info
RUN echo "Source: fermilab/gwms-workspace" > /image-source-info.txt
RUN echo "Timestamp: $(date -u +'%Y-%m-%dT%H:%M:%SZ')" | tee /image-build-info.txt
