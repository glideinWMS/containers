# SPDX-FileCopyrightText: 2020 Fermi Research Alliance, LLC
# SPDX-License-Identifier: Apache-2.0

# Parameter to allow builds for EL7/9
ARG GWMS_VERSION=latest
ARG IMAGE_NAMESPACE=glideinwms
FROM $IMAGE_NAMESPACE/gwms-workspace:$GWMS_VERSION
# NOTE: if you need GWMS_VERSION after FROM, you need to repeat it
ARG TARGETPLATFORM
ARG BUILDPLATFORM
ARG BUILD_VERSION=dev
ARG BUILD_REF
ARG BUILD_HASH
ARG BUILD_SHA
ARG BUILD_DATE
# MAINTAINER is deprecated but it is needed to set Author in the image attributes
MAINTAINER GlideinWMS Team <glideinwms@fnal.gov>
LABEL name="Devcontainer for the GlideinWMS Factory on EL7/9" \
      org.opencontainers.image.authors="GlideinWMS Team glideinwms@fnal.gov" \
      org.opencontainers.image.title="GWMS Factory Workspace" \
      org.opencontainers.image.description="Devcontainer for the GlideinWMS Factory on EL7/9" \
      org.opencontainers.image.url="https://glideinwms.fnal.gov/" \
      org.opencontainers.image.documentation="https://glideinwms.fnal.gov/" \
      org.opencontainers.image.source="https://github.com/glideinWMS/containers/tree/main/workspaces" \
      org.opencontainers.image.vendor="The GlideinWMS Team" \
      org.opencontainers.image.licenses="Apache-2.0" \
      org.opencontainers.image.revision="$BUILD_HASH" \
      org.opencontainers.image.ref.name="$BUILD_REF" \
      org.opencontainers.image.created="$BUILD_DATE"\
      org.glideinwms.image.version="$GWMS_VERSION"
# Declaring ports: webserver, htcondor(shared port)
EXPOSE 80 443 9618

RUN echo "Building Factory dev image ($BUILD_SHA/$BUILD_DATE) on $BUILDPLATFORM, for $TARGETPLATFORM"

# See gwms-workspace for the repos setup and base packages

# Install GlideinWMS Factory
RUN yum -y install --enablerepo=osg-development glideinwms-factory
RUN rm -f /etc/condor/config.d/00-minicondor

# This must be after all dnf/yum and pip commands
# Cleaning YUM and DNF all caches (including disabled repos) and pip caches to reduce size of image
RUN rm -rf /var/cache/yum/* /var/cache/dnf/* /root/.cache/pip/*

# Deploy utility scripts
COPY shared/scripts /opt/scripts
COPY factory-workspace/scripts/* /opt/scripts
RUN ln -s /opt/scripts/* /usr/local/bin

# Download HTCondor tarballs
# HTCondor 10.6.0 to test a more recent version on Alma9
# HTCondor 9.0.18 to test also hybrid configurations on EL7 (x86_64 only, leave the tar file to avoid rebuild problems)
RUN pushd /var/lib/gwms-factory/condor ;\
    wget https://research.cs.wisc.edu/htcondor/tarball/10/10.x/10.6.0/release/condor-10.6.0-$(arch)_AlmaLinux9-stripped.tar.gz ;\
    tar -xf condor-10.6.0-$(arch)_AlmaLinux9-stripped.tar.gz ;\
    rm -f condor-10.6.0-$(arch)_AlmaLinux9-stripped.tar.gz ;\
    wget https://research.cs.wisc.edu/htcondor/tarball/9.0/9.0.18/release/condor-9.0.18-x86_64_CentOS7-stripped.tar.gz ;\
    tar -xf condor-9.0.18-x86_64_CentOS7-stripped.tar.gz ;\
    popd

# Deploy GlideinWMS Factory and HTCondor configuration
COPY factory-workspace/config/glideinWMS.xml /etc/gwms-factory/glideinWMS.xml
RUN sed -i "s/\[ARCH\]/$(arch)/g" /etc/gwms-factory/glideinWMS.xml
RUN chown gfactory:gfactory /etc/gwms-factory/glideinWMS.xml
COPY shared/config/99-debug.conf /etc/condor/config.d/99-debug.conf
COPY shared/config/99-cafile.conf /etc/condor/config.d/99-cafile.conf

# Default entry point
CMD ["/bin/bash"]

# build info
RUN echo "Source: fermilab/factory-workspace" > /image-source-info.txt
RUN echo "Timestamp: $(date -u +'%Y-%m-%dT%H:%M:%SZ')" | tee /image-build-info.txt
