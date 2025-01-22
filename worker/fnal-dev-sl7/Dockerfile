# SPDX-FileCopyrightText: 2020 Fermi Research Alliance, LLC
# SPDX-License-Identifier: Apache-2.0

# Selecting SL7 as the base OS
FROM fermilab/fnal-wn-sl7:latest
MAINTAINER WMS Team "glideinwms-support@fnal.gov"
LABEL description="SL7 development container"

RUN yum -y install asciidoc autoconf automake bzip2-devel fontconfig-devel freetype-devel ftgl-devel gdbm-devel giflib-devel gl2ps-devel glew-devel glibc-devel.i686 \
    harfbuzz-devel libAfterImage-devel libXft-devel libXi-devel libXrender-devel libgcc.i686 libjpeg-turbo-devel libpng-devel libstdc++-devel.i686 libtool \
    libuuid-devel libxkbcommon-devel libxkbcommon-x11-devel lz4-devel ncurses-devel openldap-devel perl-DBD-SQLite perl-ExtUtils-MakeMaker perl-Module-Pluggable readline-devel \
    subversion swig tcl-devel texinfo tk-devel xcb-util-image-devel xcb-util-keysyms-devel xcb-util-renderutil-devel xcb-util-wm-devel xmlto xxhash-devel zstd \
    gtk2-devel motif-devel postgresql-devel sqlite-devel libxml2-devel libxslt-devel \
    python3-devel python-six emacs vim nano cvs htop curl procmail \
    autogen bison cmake3 gunzip hwloc-devel patchelf ninja-build csh tcsh zsh \
    java-latest-openjdk-devel \
    mesa-dri-drivers ddd

# Packages requiring additional repos
RUN curl -sSf 'https://packagecloud.io/install/repositories/github/git-lfs/config_file.repo?os=centos&dist=7&source=script' > /etc/yum.repos.d/github_git-lfs.repo
# Installed in sl7-base  RUN yum -y install yum-conf-context-fermilab.noarch
RUN yum -y install fermilab-util_kx509 fermilab-conf_kerberos \
    git-lfs \
    && yum -y clean all

# Default entry point
CMD ["/bin/bash"]

# build info
RUN echo "Source: fermilab/fnal-dev-sl7" > /image-source-info.txt
RUN echo "Timestamp:" `date --utc` | tee /image-build-info.txt
