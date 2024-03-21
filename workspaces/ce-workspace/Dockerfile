# SPDX-FileCopyrightText: 2020 Fermi Research Alliance, LLC
# SPDX-License-Identifier: Apache-2.0

ARG IMAGE_NAMESPACE=glideinwms
FROM $IMAGE_NAMESPACE/gwms-workspace
LABEL org.opencontainers.image.authors="marcom@fnal.gov,coimbra@fnal.gov"
LABEL name="Devcontainer for an EL9 HTCondorCE to be used for GlideinWMS testing"

# See gwms-workspace for the repos setup and base packages

# Install HTCondor-CE
RUN dnf -y install htcondor-ce-condor

# Install development tools
RUN dnf config-manager --add-repo https://cli.github.com/packages/rpm/gh-cli.repo ;\
    dnf install -y gh vim zsh sudo psmisc bind-utils mlocate ;\
    pip3 install debugpy ;

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
RUN echo "Timestamp:" `date --utc` | tee /image-build-info.txt
