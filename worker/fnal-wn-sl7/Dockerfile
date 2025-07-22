# SPDX-FileCopyrightText: 2020 Fermi Research Alliance, LLC
# SPDX-License-Identifier: Apache-2.0

# Selecting SL7 as the base OS
FROM fermilab/base-sl7:latest
MAINTAINER Marco Mambelli "marcom@fnal.gov"
LABEL name="FNAL Worker Node on SL7 with OSG 3.6 Worker Node Client"

# Installing packages
# Singularity version has been explicitly specified to control upgrades
# xrootd packages have been version locked as well to control upgrades
# Updated xrootd and Singularity versions, out of sync w/ GCO: RUN yum install -y gcc-c++ libstdc++ xrootd-client-libs-4.11.1-1.osg35.el7.x86_64 xrootd-libs-4.11.1-1.osg35.el7.x86_64 xrootd-client-4.11.1-1.osg35.el7.x86_64 osg-wn-client krb5-workstation strace redhat-lsb-core mesa-libGLU mesa-libGLU-devel libXmu cvmfs gstreamer-plugins-base libXScrnSaver libSM-devel libXpm-devel libgfortran glibc.i686 libXmu libXmu-devel expat-devel libxml2-devel mysql-libs libtiff libjpeg-turbo openssh-clients openssl-devel tzdata glibc-headers glibc-devel singularity-3.5.3-1.1.el7.x86_64 ;\
# Added libraries from FNAL requests are labeled with "LIBRARIES (optional comment) [VO, requestor, SNOW req. number]
#  mpich mpich-devel numactl numactl-devel (MPI libraries) [, M.Paterno, ] libffi libffi-devel [DES, M, Paterno, RITM1038430]
#  pcre2 xxhash-libs libzstd libzstd-devel [Art v3_06, R.Kutschke, RITM1002405]
#  libcurl-devel [Minerva, K.Herner, RITM1036665]
#  ftgl gl2ps libGLEW giflib libAfterImage [LArSoft v09_16_00, V. Di Benedetto, RITM1085514]
#  perl libraries: perl perl-autodie ...  perl-Scalar-List-Utils [Mu2e S.Soleti R.Kutschke, INC000001118312]
#  jq [SBND Mateus F. Carneiro, RITM1235906]
#  htgettoken [Mu2e, Ray Culbertson, as part of RITM1572512]
#  pcre2-devel [Mu2e, Ray Culbertson, RITM1593912]
#  perl-JSON perl-Archive-Tar perl-IO-Compress [Mu2e, RITM2002927]
#  bind-utils [Steve Timm RITM2399939]
# OSG has only: osg-wn-client redhat-lsb-core singularity
# removed:  gfal2-plugin-xrootd-2.18.1-2.el7.x86_64, verify why it was added, now also in OSG, it is a dependency of osg-wn-client
# TODO: temporary using osg-development, should be removed after 11/5
#  removed --enablerepo=osg-testing 2020-07-09
RUN yum install -y \
    osg-ca-certs \
    gcc-c++ libstdc++ xrootd-client-libs xrootd-libs xrootd-client osg-wn-client krb5-workstation strace redhat-lsb-core mesa-libGLU mesa-libGLU-devel libXmu cvmfs gstreamer-plugins-base libXScrnSaver libSM-devel libXpm-devel libgfortran glibc.i686 libXmu libXmu-devel expat-devel libxml2-devel mysql-libs libtiff libjpeg-turbo openssh-clients openssl-devel tzdata glibc-headers glibc-devel \
    pcre2 pcre2-devel xxhash-libs libzstd libzstd-devel mpich mpich-devel numactl numactl-devel libffi libffi-devel libcurl-devel \
    ftgl gl2ps libGLEW giflib libAfterImage \
    perl perl-autodie perl-Carp perl-constant perl-Data-Dumper perl-Digest perl-Digest-SHA perl-Exporter perl-File-Path perl-File-Temp perl-Getopt-Long perl-libs perl-PathTools perl-Scalar-List-Utils \
    perl-JSON perl-Archive-Tar perl-IO-Compress \
    jq \
    globus-gass-copy-progs globus-proxy-utils globus-xio-udt-driver gfal2-plugin-gridftp gfal2-plugin-srm uberftp \
    fts-client gsi-openssh-clients myproxy voms-clients-cpp stashcp \
    python-setuptools python2-future python-backports-ssl_match_hostname python2-gfal2-util \
    bind-utils && \
    chmod ugo+rx /usr/bin/ssh-agent

# Installing apptainer 1.2.5 (+requirements) and not 1.3 from EPEL, to be able to use underlay on EL7 nodes
RUN yum install -y fuse2fs && \
    yum install -y https://github.com/apptainer/apptainer/releases/download/v1.2.5/apptainer-1.2.5-1.x86_64.rpm

# Leaving the default apptainer configuration
# ADD shared/singularity.conf /etc/singularity/singularity.conf

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
RUN echo "Source: fermilab/fnal-wn-sl7" > /image-source-info.txt
RUN echo "Timestamp:" `date --utc` | tee /image-build-info.txt
