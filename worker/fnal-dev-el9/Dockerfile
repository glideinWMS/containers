# SPDX-FileCopyrightText: 2020 Fermi Research Alliance, LLC
# SPDX-License-Identifier: Apache-2.0

# Selecting AlmaLinux 9 as the base OS
FROM fermilab/fnal-wn-el9:latest
MAINTAINER Marco Mambelli "marcom@fnal.gov"
LABEL name="Extra packages needed by Spack on top of FNAL Worker Node on EL9 with OSG 23 Worker Node Client"

# Installing packages
RUN yum install -y --enablerepo=crb --enablerepo=osg \
    asciidoc autoconf automake bison cigetcert cmake libcurl libcurl-devel flex gdbm gdbm-devel \
    gtk3 gtk3-devel gperf help2man condor libfontenc libfontenc-devel libtool libtool-ltdl-devel \
    libxkbcommon libxkbcommon-devel meson  nasm ninja-build patchelf texinfo  texlive tk tk-devel \
    xorg-x11-util-macros xorg-x11-xtrans-devel 

# Default entry point
CMD ["/bin/bash"]


# Cleaning caches to reduce size of image
RUN yum clean all

# build info
RUN echo "Source: fermilab/fnal-dev-el9" > /image-source-info.txt
RUN echo "Timestamp:" `date --utc` | tee /image-build-info.txt
