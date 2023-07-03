# SPDX-FileCopyrightText: 2020 Fermi Research Alliance, LLC
# SPDX-License-Identifier: Apache-2.0

FROM localhost/gwms-workspace-arm64
LABEL org.opencontainers.image.authors="marcom@fnal.gov,coimbra@fnal.gov"
LABEL name="Devcontainer for the GlideinWMS Factory"

# See gwms-workspace for the repos setup and base packages

# build info
RUN echo "Source: fermilab/factory-workspace" > /image-source-info.txt
RUN echo "Timestamp:" `date --utc` | tee /image-build-info.txt

# Install GlideinWMS Factory
RUN yum -y install --enablerepo=osg-development glideinwms-factory
RUN rm -f /etc/condor/config.d/00-minicondor

# Install development tools
RUN dnf config-manager --add-repo https://cli.github.com/packages/rpm/gh-cli.repo ;\
    dnf install -y gh vim zsh sudo psmisc bind-utils mlocate ;\
    pip3 install debugpy ;

#################################
# Cleaning caches to reduce size of image
RUN dnf clean all

# Deploy utility scripts
COPY scripts /opt/GlideinWMS/scripts

# Dowload HTCondor tarballs
RUN pushd /var/lib/gwms-factory/condor ;\
    wget https://research.cs.wisc.edu/htcondor/tarball/10/10.x/10.6.0/release/condor-10.6.0-x86_64_AlmaLinux9-stripped.tar.gz ;\
    tar -xf condor-10.6.0-x86_64_AlmaLinux9-stripped.tar.gz ;\
    rm -f condor-10.6.0-x86_64_AlmaLinux9-stripped.tar.gz ;\
    popd

# Deploy GlideinWMS Factory configuration
COPY config/glideinWMS.xml /etc/gwms-factory/glideinWMS.xml
RUN chown gfactory:gfactory /etc/gwms-factory/glideinWMS.xml
COPY config/99-local.conf /etc/condor/config.d/99-local.conf

# Default entry point
CMD ["/bin/bash"]
