# SPDX-FileCopyrightText: 2020 Fermi Research Alliance, LLC
# SPDX-License-Identifier: Apache-2.0

FROM localhost/gwms-workspace-arm64
LABEL org.opencontainers.image.authors="marcom@fnal.gov,coimbra@fnal.gov"
LABEL name="Devcontainer for the GlideinWMS Frontend"

# See gwms-workspace for the repos setup and base packages

# build info
RUN echo "Source: fermilab/frontend-workspace" > /image-source-info.txt
RUN echo "Timestamp:" `date --utc` | tee /image-build-info.txt

# Install GlideinWMS Frontend
RUN yum -y install --enablerepo=osg-development glideinwms-vofrontend
RUN rm -f /etc/condor/config.d/00-minicondor

# Install development tools
RUN dnf config-manager --add-repo https://cli.github.com/packages/rpm/gh-cli.repo ;\
    dnf install -y gh vim zsh sudo psmisc bind-utils mlocate ;\
    pip3 install debugpy ;

#################################
# Cleaning caches to reduce size of image
RUN yum clean all

# Deploy utility scripts
COPY scripts /opt/GlideinWMS/scripts

# Deploy GlideinWMS Frontend configuration
COPY config/frontend.xml /etc/gwms-frontend/frontend.xml
RUN chown frontend:frontend /etc/gwms-frontend/frontend.xml

# Add test user
RUN useradd testuser
COPY --chown=testuser:testuser testuser-home /home/testuser/* /home/testuser/

# Default entry point
CMD ["/bin/bash"]
