# SPDX-FileCopyrightText: 2020 Fermi Research Alliance, LLC
# SPDX-License-Identifier: Apache-2.0

FROM gwmsdeveloper/gwms-workspace
LABEL org.opencontainers.image.authors="marcom@fnal.gov,coimbra@fnal.gov"
LABEL name="Devcontainer for the GlideinWMS Factory"

# See gwms-workspace for the repos setup and base packages

# Install HTCondor-CE
RUN dnf -y install htcondor-ce-condor

# Install development tools
RUN dnf config-manager --add-repo https://cli.github.com/packages/rpm/gh-cli.repo ;\
    dnf install -y gh vim zsh sudo psmisc bind-utils mlocate ;\
    pip3 install debugpy ;

# Deploy utility scripts
COPY scripts /opt/GlideinWMS/scripts

# Deploy HTCondor-CE configuration
COPY config/10-local.conf /etc/condor/config.d/10-local.conf
COPY config/10-scitokens.conf /etc/condor-ce/mapfiles.d/10-scitokens.conf
COPY config/99-local.conf /etc/condor-ce/config.d/99-local.conf
RUN rm -f /etc/condor/config.d/00-minicondor

# Add fermilab user
RUN useradd fermilab

# Default entry point
CMD ["/bin/bash"]
