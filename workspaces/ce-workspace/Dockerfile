# SPDX-FileCopyrightText: 2020 Fermi Research Alliance, LLC
# SPDX-License-Identifier: Apache-2.0

ARG IMAGE_NAMESPACE=glideinwms
FROM $IMAGE_NAMESPACE/gwms-workspace
ARG TARGETPLATFORM
ARG BUILDPLATFORM
ARG BUILD_VERSION=dev
ARG BUILD_REF
ARG BUILD_HASH
ARG BUILD_SHA
ARG BUILD_DATE
# MAINTAINER is deprecated but it is needed to set Author in the image attributes
MAINTAINER GlideinWMS Team <glideinwms@fnal.gov>
LABEL name="Devcontainer for an EL9 HTCondorCE and worker to be used for GlideinWMS testing" \
      org.opencontainers.image.authors="GlideinWMS Team glideinwms@fnal.gov" \
      org.opencontainers.image.title="All-in-one HTCondorCE Workspace" \
      org.opencontainers.image.description="Devcontainer for an EL9 HTCondorCE and worker to be used for GlideinWMS testing" \
      org.opencontainers.image.url="https://glideinwms.fnal.gov/" \
      org.opencontainers.image.documentation="https://glideinwms.fnal.gov/" \
      org.opencontainers.image.source="https://github.com/glideinWMS/containers/tree/main/workspaces" \
      org.opencontainers.image.vendor="The GlideinWMS Team" \
      org.opencontainers.image.licenses="Apache-2.0" \
      org.opencontainers.image.revision="$BUILD_HASH" \
      org.opencontainers.image.ref.name="$BUILD_REF" \
      org.opencontainers.image.created="$BUILD_DATE"
# Declaring ports: htcondor-CE(shared port)
EXPOSE 9619

RUN echo "Building CE dev image ($BUILD_SHA/$BUILD_DATE) on $BUILDPLATFORM, for $TARGETPLATFORM"

# See gwms-workspace for the repos setup and base packages

# Install HTCondor-CE
RUN dnf -y install htcondor-ce-condor

# Install development tools
RUN dnf config-manager --add-repo https://cli.github.com/packages/rpm/gh-cli.repo ;\
    dnf install -y gh vim zsh sudo psmisc bind-utils mlocate ;\
    pip3 install debugpy ;

# This must be after all dnf/yum and pip commands
# Cleaning YUM and DNF all caches (including disabled repos) and pip caches to reduce size of image
RUN rm -rf /var/cache/yum/* /var/cache/dnf/* /root/.cache/pip/*

# Deploy utility scripts
COPY ce-workspace/scripts /root/scripts
COPY shared/scripts/create-host-certificate.sh /root/scripts/
RUN ln -s /root/scripts/* /usr/local/bin

# Deploy HTCondor-CE configuration
COPY ce-workspace/config/10-local.conf /etc/condor/config.d/10-local.conf
COPY shared/config/99-debug.conf /etc/condor/config.d/99-debug.conf
COPY ce-workspace/config/10-scitokens.conf /etc/condor-ce/mapfiles.d/10-scitokens.conf
COPY ce-workspace/config/99-local.conf /etc/condor-ce/config.d/99-local.conf
COPY shared/config/99-debug.conf /etc/condor-ce/config.d/99-debug.conf
RUN rm -f /etc/condor/config.d/00-minicondor

# Add fermilab and osg (allows for Google CA in CILogon) users
RUN useradd fermilab ;\
    useradd osg

# Default entry point
CMD ["/bin/bash"]

# build info
RUN echo "Source: fermilab/ce-workspace" > /image-source-info.txt
RUN echo "Timestamp: $(date -u +'%Y-%m-%dT%H:%M:%SZ')" | tee /image-build-info.txt
