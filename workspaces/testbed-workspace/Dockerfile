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
ARG GWMS_VERSION=latest
# MAINTAINER is deprecated but it is needed to set Author in the image attributes
MAINTAINER GlideinWMS Team <glideinwms@fnal.gov>
LABEL name="Testbed workspace with EL9 and utility scripts" \
      org.opencontainers.image.authors="GlideinWMS Team glideinwms@fnal.gov" \
      org.opencontainers.image.title="GWMS Testbed Workspace" \
      org.opencontainers.image.description="Testbed workspace with EL9 and utility scripts" \
      org.opencontainers.image.url="https://glideinwms.fnal.gov/" \
      org.opencontainers.image.documentation="https://glideinwms.fnal.gov/" \
      org.opencontainers.image.source="https://github.com/glideinWMS/containers/tree/main/workspaces" \
      org.opencontainers.image.vendor="The GlideinWMS Team" \
      org.opencontainers.image.licenses="Apache-2.0" \
      org.opencontainers.image.revision="$BUILD_HASH" \
      org.opencontainers.image.ref.name="$BUILD_REF" \
      org.opencontainers.image.created="$BUILD_DATE"\
      org.glideinwms.image.version="$GWMS_VERSION"

RUN echo "Building GWMS Testbed image ($BUILD_SHA/$BUILD_DATE) on $BUILDPLATFORM, for $TARGETPLATFORM"

# Installing some base packages, the CRB repo, and the EPEL (epel-release)
RUN dnf install -y epel-release yum-utils sed wget && \
    dnf config-manager --set-enabled crb && \
    /bin/sed -i '/^enabled=1/a priority=99' /etc/yum.repos.d/epel.repo

# Installing some system management RPMs/sw needed for containers (these are not needed for VMs)
RUN dnf install -y cronie supervisor initscripts ;\
    /usr/bin/wget https://raw.githubusercontent.com/gdraheim/docker-systemctl-replacement/master/files/docker/systemctl3.py -O /usr/local/bin/systemctl ;\
    /usr/bin/chmod +x /usr/local/bin/systemctl

# htgettoken needs the OSG repo
# Installing htgettoken
# RUN dnf -y install htgettoken

# Consider the following for FNAL kinit/kx509/...
# krb5-workstation yum-conf-context-fermilab fermilab-util_kx509 fermilab-conf_kerberos


# This must be after all dnf/yum and pip commands
# Cleaning YUM and DNF all caches (including disabled repos) and pip caches to reduce size of image
RUN rm -rf /var/cache/yum/* /var/cache/dnf/* /root/.cache/pip/*

# Adding unprivileged users
RUN adduser abc ;\
    mkdir /home/abc/repos && \
    chown abc: /home/abc/repos ;\
    mkdir /opt/abc && \
    chown abc: /opt/abc
RUN useradd testuser
COPY --chown=testuser:testuser frontend-workspace/testuser-home/* /home/testuser/

# Deploy utility scripts
COPY testbed-workspace/scripts /opt/scripts
COPY shared/scripts/* /opt/scripts
COPY frontend-workspace/scripts/run-test.sh /opt/scripts
RUN ln -s /opt/scripts/* /usr/local/bin

# Deploy GlideinWMS Frontend and HTCondor configuration
RUN mkdir -p /opt/config/factory /opt/config/frontend
COPY shared/config/* /opt/config
COPY factory-workspace/config/glideinWMS.xml /opt/config/factory
COPY frontend-workspace/config/frontend.xml /opt/config/frontend
RUN sed -i "s/\[ARCH\]/$(arch)/g" /opt/config/factory/glideinWMS.xml

# Deploy secrets
COPY gwms-workspace/secrets /opt/localgwms/secrets

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

# build info
RUN echo "Source: glideinwms/testbed-workspace" > /image-source-info.txt
RUN echo "Timestamp: $(date -u +'%Y-%m-%dT%H:%M:%SZ')" | tee /image-build-info.txt
