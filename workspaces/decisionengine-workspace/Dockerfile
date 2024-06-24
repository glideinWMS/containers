# SPDX-FileCopyrightText: 2020 Fermi Research Alliance, LLC
# SPDX-License-Identifier: Apache-2.0

# DE Workspace
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
LABEL name="Workspace with EL9, OSG 3.6 and the HEPCloud Decision Engine" \
      org.opencontainers.image.authors="GlideinWMS Team glideinwms@fnal.gov" \
      org.opencontainers.image.title="HEPCloud Decision Engine Workspace" \
      org.opencontainers.image.description="Workspace with EL9, OSG 3.6 and the HEPCloud Decision Engine" \
      org.opencontainers.image.url="https://hepcloud.github.io/" \
      org.opencontainers.image.documentation="https://hepcloud.github.io/" \
      org.opencontainers.image.source="https://github.com/glideinWMS/containers/tree/main/workspaces" \
      org.opencontainers.image.vendor="The GlideinWMS Team" \
      org.opencontainers.image.licenses="Apache-2.0" \
      org.opencontainers.image.revision="$BUILD_HASH" \
      org.opencontainers.image.ref.name="$BUILD_REF" \
      org.opencontainers.image.created="$BUILD_DATE"
# Declaring ports: webserver, htcondor(shared port)
EXPOSE 80 9618

RUN echo "Building DE dev image ($BUILD_SHA/$BUILD_DATE) on $BUILDPLATFORM, for $TARGETPLATFORM"

# See gwms-workspace for the repos setup and base packages

RUN dnf install -y postgresql postgresql-server postgresql-devel && systemctl enable postgresql && postgresql-setup --initdb ;\
    postgresql-setup --initdb
    yum -y install --enablerepo=osg-development glideinwms-vofrontend

ADD pg_hba.conf /var/lib/pgsql/data/pg_hba.conf

RUN systemctl start postgresql ;\
    createdb -U postgres decisionengine ;\
    export PG_VERSION=13 ;\
    export PATH="~/.local/bin:$PATH"
# you may also add these lines to ~/.bashrc

RUN python3 -m pip install --upgrade --user pip ;\
    python3 -m pip install --upgrade --user setuptools wheel setuptools-scm[toml]

RUN wget -O /etc/yum.repos.d/ssi-hepcloud-dev.repo http://ssi-rpm.fnal.gov/hep/ssi-hepcloud-dev.repo ;\
    wget -O /tmp/yumalldeps.sh https://raw.githubusercontent.com/glideinWMS/containers/main/worker/shared/yumalldeps.sh ;\
    chmod +x /tmp/yumalldeps.sh ;\
    /tmp/yumalldeps.sh -i -f decisionengine decisionengine ;\
    /tmp/yumalldeps.sh -i -f decisionengine decisionengine_modules

# There are missing dependencies, so the above workaround (these will be installed via pip below)
#    yum -y install --enablerepo=ssi-hepcloud-dev decisionengine ;\
#    yum -y install --enablerepo=ssi-hepcloud-dev decisionengine_modules
# repoquery -q --location decisionengine.noarch | tail -n 1
# rpm -Uvh --nodeps $(repoquery -q --location decisionengine.noarch | tail -n 1)

# Clone decisionengine and decisionengine_modules repo in /home/abc/repos
RUN cd /home/abc/repos ;\
    su decisionengine -s /bin/bash
git clone https://github.com/HEPCloud/decisionengine.git ;\
git clone https://github.com/HEPCloud/decisionengine_modules.git
exit ;\
    su decisionengine -s /bin/bash
python3 -m pip install --upgrade pip setuptools wheel --user
python3 /home/abc/repos/decisionengine/setup.py develop --user
python3 /home/abc/repos/decisionengine/setup.py develop --user --uninstall
python3 /home/abc/repos/decisionengine_modules/setup.py develop --user
python3 /home/abc/repos/decisionengine_modules/setup.py develop --user --uninstall
exit


# links, ... to work from git

# DE configuration
# Setup with standard environment


# Default entry point
CMD ["/bin/bash"]

# This must be after all dnf/yum and pip commands
# Cleaning YUM and DNF all caches (including disabled repos) and pip caches to reduce size of image
RUN rm -rf /var/cache/yum/* /var/cache/dnf/* /root/.cache/pip/*

# build info
RUN echo "Source: $IMAGE_NAMESPACE/decisonengine-workspace" > /image-source-info.txt
RUN echo "Timestamp: $(date -u +'%Y-%m-%dT%H:%M:%SZ')" | tee /image-build-info.txt
