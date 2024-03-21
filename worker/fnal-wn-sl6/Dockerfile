# SPDX-FileCopyrightText: 2020 Fermi Research Alliance, LLC
# SPDX-License-Identifier: Apache-2.0

# Selecting SL6 as the base OS
FROM fermilab/fnal-wn-sl6:2.0
MAINTAINER Marco Mambelli "marcom@fnal.gov"

# The base image was built Nov 4 2020 using the description currently in Dockerfile.from_scratch in this repo
# Due to repository unavailability that image cannot be built any more
# fermilab/fnal-wn-sl6:2.0 and fermilab/fnal-wn-sl6:last_from_repos are the same

# Updated repos
COPY fnal-wn-sl6/sl6x.repo /etc/yum.repos.d/sl6x.repo
COPY fnal-wn-sl6/sl-other.repo /etc/yum.repos.d/sl-other.repo
COPY fnal-wn-sl6/sl.repo /etc/yum.repos.d/sl.repo
# OSG 3.4 EL6 repo
COPY fnal-wn-sl6/osg-el6.repo /etc/yum.repos.d/osg-el6.repo

# MiniBoone RPMs
# RUN yum -y install zlib.i686 libstdc++.i686 libXpm.i686 libXt.i686 libXext.i686 libSM.i686 libICE.i686 libXmu.i686 openssl.i686 libaio.i686 compat-libf2c-34-3.4.6-19.el6.i686 \
# Other
# RUN yum -y install zlib.i686 libstdc++.i686 libXpm.i686 compat-gcc-34-g77 openssl-libs libaio \
# CA certs from RPM (osg3.6, el7)
# RUN yum -y install osg-ca-certs-1.116-3.osg36.el7.noarch.rpm \
# && yum -y clean all

# Overriding the CA certificates with updated ones
RUN wget -q -O- https://glideinwms.fnal.gov/downloads/osg-ca-certificates.tar.gz | \
    tar -xz -C /etc/grid-security/certificates/ --overwrite && \
    chown root: /etc/grid-security/certificates/*

# Postponing yum clean all to later, after the git installation
# Skipping additional FermiGrid specific tests:
# - adding /home/interactive
# - adding the tests

# Default entry point
CMD ["/bin/bash"]

# build info
RUN echo "Source: fermilab/fnal-wn-sl6" > /image-source-info.txt
RUN echo "Timestamp:" `date --utc` | tee /image-build-info.txt
