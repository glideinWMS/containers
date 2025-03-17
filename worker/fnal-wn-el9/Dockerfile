# SPDX-FileCopyrightText: 2020 Fermi Research Alliance, LLC
# SPDX-License-Identifier: Apache-2.0

# Selecting AlmaLinux 9 as the base OS
FROM almalinux:9
MAINTAINER Marco Mambelli "marcom@fnal.gov"
LABEL name="FNAL Worker Node on EL9 with OSG 23 Worker Node Client"

# Starting OSG 23 the HTCondor Madison repository is in synch with the OSG one so I'm removing it from the container.
# HTCondor, if needed, will be installed from the OSG repository

# Next setting up EPEL and OSG repositories
# OSG by default has a YUM  prio of 98
# Assigning EPEL YUM prio of 99
RUN yum -y install wget sed https://dl.fedoraproject.org/pub/epel/epel-release-latest-9.noarch.rpm ;\
    yum -y install https://repo.opensciencegrid.org/osg/23-main/osg-23-main-el9-release-latest.rpm \
                   epel-release ;\
    /bin/sed -i '/^enabled=1/a priority=99' /etc/yum.repos.d/epel.repo

# Installing packages
# Singularity version has been explicitly specified to control upgrades
# xrootd packages have been version locked as well to control upgrades
# Updated xrootd and Singularity versions, out of sync w/ GCO: RUN yum install -y gcc-c++ libstdc++ xrootd-client-libs-4.11.1-1.osg35.el7.x86_64 xrootd-libs-4.11.1-1.osg35.el7.x86_64 xrootd-client-4.11.1-1.osg35.el7.x86_64 osg-wn-client krb5-workstation strace redhat-lsb-core mesa-libGLU mesa-libGLU-devel libXmu cvmfs gstreamer-plugins-base libXScrnSaver libSM-devel libXpm-devel libgfortran glibc.i686 libXmu libXmu-devel expat-devel libxml2-devel mysql-libs libtiff libjpeg-turbo openssh-clients openssl-devel tzdata glibc-headers glibc-devel singularity-3.5.3-1.1.el7.x86_64 ;\
# Added libraries from FNAL requests are labeled with "LIBRARIES (optional comment) [VO, requestor, SNOW req. number]
#  mpich mpich-devel numactl numactl-devel (MPI libraries) [, M.Paterno, ] libffi libffi-devel [DES, M, Paterno, RITM1038430]
#  pcre2 xxhash-libs libzstd libzstd-devel [Art v3_06, R.Kutschke, RITM1002405]
#  libcurl-devel [Minerva, K.Herner, RITM1036665]
#  ftgl gl2ps libGLEW giflib libAfterImage [LArSoft v09_16_00, V. Di Benedetto, RITM1085514]
#  jq [SBND Mateus F. Carneiro, RITM1235906]
#  htgettoken [Mu2e, Ray Culbertson, as part of RITM1572512]
#  bzip2 [Mu2e, Ray Culbertson, as part of RITM2052307]
#  perl-JSON perl-Archive-Tar perl-IO-Compress [Mu2e, RITM2142780]
#  perl-autodie perl-English [Mu2e, RITM2191006]
#  bind-utils [Steve Timm RITM2399939]
# OSG has only: osg-wn-client redhat-lsb-core singularity
# removed:  gfal2-plugin-xrootd-2.18.1-2.el7.x86_64, verify why it was added, now in OSG
# TODO: temporary using osg-development, should be removed after 11/5
#RUN yum install -y  --enablerepo=PowerTools  --enablerepo=osg-development redhat-lsb-core \
#        gcc-c++ libstdc++ xrootd-client-libs-4.12.1-1.osg35.el8.x86_64 xrootd-libs-4.12.1-1.osg35.el8.x86_64 xrootd-client-libs-4.12.1-1.osg35.el8.x86_64 gfal2-plugin-xrootd \
#        osg-wn-client krb5-workstation strace redhat-lsb-core mesa-libGLU mesa-libGLU-devel libXmu cvmfs gstreamer-plugins-base libXScrnSaver libSM-devel libXpm-devel libgfortran glibc.i686 \
#        libXmu libXmu-devel expat-devel libxml2-devel mysql-libs libtiff libjpeg-turbo openssh-clients openssl-devel tzdata glibc-headers glibc-devel mpich mpich-devel numactl numactl-devel \
#        singularity
RUN yum install -y --enablerepo=crb --enablerepo=osg \
    osg-ca-certs \
    gcc-c++ libstdc++ xrootd-client-libs xrootd-libs xrootd-client-libs gfal2-plugin-xrootd \
    osg-wn-client krb5-workstation strace mesa-libGLU mesa-libGLU-devel libXmu libXmu-devel cvmfs libXScrnSaver libSM-devel libXpm-devel libgfortran glibc.i686 \
    expat-devel libxml2-devel mysql-libs libtiff libjpeg-turbo openssh-clients openssl-devel tzdata glibc-headers glibc-devel \
    pcre2 xxhash-libs libzstd libzstd-devel mpich mpich-devel numactl numactl-devel libffi libffi-devel libcurl-devel \
    ftgl gl2ps libGLEW giflib libAfterImage \
    jq htgettoken bzip2 perl-JSON perl-Archive-Tar perl-IO-Compress perl-File-Copy perl-File-Copy-Recursive perl-File-Copy-Recursive-Reduced perl-autodie perl-English \
    globus-gass-copy-progs globus-proxy-utils globus-xio-udt-driver gfal2-plugin-gridftp gfal2-plugin-srm uberftp \
    gsi-openssh-clients myproxy voms-clients-cpp stashcp \
    python3-setuptools python3-future python3-gfal2-util python-unversioned-command \
    bind-utils

# Installing apptainer 1.2.5 (+requirements) and not 1.3 from EPEL, to be able to use underlay on EL7 nodes
RUN dnf install -y https://github.com/apptainer/apptainer/releases/download/v1.2.5/apptainer-1.2.5-1.x86_64.rpm

# NOTE: redhat-lsb-core package is made available through AlmaLinux Devel repo
RUN dnf install -y almalinux-release-devel
RUN dnf install -y redhat-lsb-core


# Overriding the default apptainer configuration
ADD shared/apptainer.conf /etc/apptainer/apptainer.conf

# SSH config needs to be added
ADD shared/ssh_config /etc/ssh/ssh_config

# Postponing yum clean all to later, after the git installation
# Skipping additional FermiGrid specific tests:
# - adding /home/interactive
# - adding the tests

# Default entry point
CMD ["/bin/bash"]


#######################
# Parts added

# osg-wn-client already installed and osg-ca-certs is a dependency. Should CRLs (.r0) be removed?
#RUN yum -y install osg-ca-certs osg-wn-client \
#    && rm -f /etc/grid-security/certificates/*.r0

#################################
# Temporary fix - Manually add Singularity files
# repo done on 8/29 by UNL sysadmin
# Files content from: https://github.com/sylabs/singularity/blob/master/internal/pkg/build/sources/base_environment.go

RUN yum install -y git && \
    git clone https://github.com/jthiltges/singularity-environment.git /usr/singularity-environment/ && \
    cp -r /usr/singularity-environment/{environment,.exec,.run,.shell,singularity,.singularity.d,.test} / && \
    mkdir /.singularity.d/libs

# Cleaning caches to reduce size of image
RUN yum clean all

# OSG suggested mount points
RUN for MNTPOINT in \
        /cvmfs \
        /hadoop \
        /hdfs \
        /lizard \
        /mnt/hadoop \
        /mnt/hdfs \
        /xenon \
        /scratch \
        /spt \
        /stash2 \
    ; do \
        mkdir -p $MNTPOINT ; \
    done

# build info
RUN echo "Source: fermilab/fnal-wn-el9" > /image-source-info.txt
RUN echo "Timestamp:" `date --utc` | tee /image-build-info.txt
