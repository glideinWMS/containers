# SPDX-FileCopyrightText: 2020 Fermi Research Alliance, LLC
# SPDX-License-Identifier: Apache-2.0

# Selecting AlmaLinux 9 as the base OS
FROM almalinux:9
MAINTAINER Marco Mambelli "marcom@fnal.gov"
LABEL name="Base workspace with EL9, OSG 3.6 and base packages required by GlideinWMS and HEPCloud"

# !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
# !!! WARNING: OSG doesn't support arm64. This is an experimental image. Use with caution. !!!
# !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!

# Installing some base packages, the CRB repo, needed by swig, and the EPEL (epel-release) and OSG repos
# Not installing epel-next-release, consider it for the future
# Not installing the HTCondor Madison repo (getting condor from OSG). In case needed (x509 is in HTCSS 9.0.x from HTCondor)
#    /usr/bin/wget http://research.cs.wisc.edu/htcondor/yum/repo.d/htcondor-stable-rhel9.repo -O /etc/yum.repos.d/condor.repo ;\
#    /usr/bin/wget http://research.cs.wisc.edu/htcondor/yum/RPM-GPG-KEY-HTCondor -O /etc/pki/rpm-gpg/RPM-GPG-KEY-HTCondor ;\
#    echo "priority=90" >> /etc/yum.repos.d/condor.repo ;\
#    echo "exclude=*.i686" >> /etc/yum.repos.d/condor.repo ;\
#    echo "gpgkey=file:///etc/pki/rpm-gpg/RPM-GPG-KEY-HTCondor" >> /etc/yum.repos.d/condor.repo
#    echo "exclude=*condor*" >> /etc/yum.repos.d/osg.repo
# Assigning the apel repo prio of 99 to make sure it is after the OSG one (98 by default)
# Installing wget to help with repo setup
RUN dnf install -y wget sed git yum-utils ;\
    dnf config-manager --set-enabled crb ;\
    dnf install -y epel-release ;\
    /bin/sed -i '/^enabled=1/a priority=99' /etc/yum.repos.d/epel.repo ;\
    dnf install -y https://repo.opensciencegrid.org/osg/3.6/osg-3.6-el9-release-latest.rpm ;\
    sed -i 's/\$basearch/x86_64/g' /etc/yum.repos.d/osg*
    # TODO: remove the sed command above when OSG supports arm64

# Installing some system management RPMs/sw needed for containers (these are not needed for VMs)
RUN dnf install -y cronie supervisor initscripts;\
    /usr/bin/wget https://raw.githubusercontent.com/gdraheim/docker-systemctl-replacement/master/files/docker/systemctl3.py -O /usr/local/bin/systemctl ;\
    /usr/bin/chmod +x /usr/local/bin/systemctl

# Installing some base RPMs (gettext is needed by RELEASE, swig and many devel by jsonnet)
RUN dnf install -y python3 python3-devel python3-cryptography python3-wheel make openssl-devel gcc gcc-c++ rpm-build gettext swig ;
    

# Packages useful for development and administration
# Common packages for all GlideinWMS/HEPCloud software
RUN dnf -y install jq apptainer ;\
    dnf -y install python3-rrdtool osg-ca-certs ;
    # NOTE: .bash_aliases doesn't seem to be compatible with ALMA Linux 9
    #/usr/bin/curl -L -o ~/.bash_aliases https://raw.githubusercontent.com/glideinWMS/dev-tools/master/.bash_aliases 2>/dev/null && . ~/.bash_aliases && aliases-update ;

# Installing HTCondor
# NOTE: OSG repos do not provide noarch HTCondor RPMs. Using https://get.htcondor.org
RUN curl -fsSL https://get.htcondor.org | /bin/bash -s -- --no-dry-run

# Installing htgettoken from source
# NOTE: htgettoken is not available in OSG 3.6 for EL9
RUN dnf -y install krb5-devel ;\
    git clone https://github.com/fermitools/htgettoken.git /opt/htgettoken; \
    pip install /opt/htgettoken/
    
# Adding unprivileged user
RUN adduser abc ;\
    mkdir /home/abc/repos && \
    chown abc: /home/abc/repos ;\
    mkdir /opt/abc && \
    chown abc: /opt/abc

# Deploy secrets
COPY secrets /opt/GlideinWMS/secrets


# Should ssh be enabled/installed?
# SSH config needs to be added
#ADD shared/ssh_config /etc/ssh/ssh_config

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
# Cleaning caches to reduce size of image
RUN dnf clean all

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
RUN echo "Source: fermilab/gwms-workspace" > /image-source-info.txt
RUN echo "Timestamp:" `date --utc` | tee /image-build-info.txt
