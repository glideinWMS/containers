FROM opensciencegrid/software-base:3.5-el7-release
LABEL maintainer OSG Software <help@opensciencegrid.org>

# Create the frontend user with a fixed GID/UID
# This is important so that we can use the same IDs in the persistent volume used for
# the web-area
RUN groupadd -o -g 993 frontend
RUN useradd -o -u 996 -g 993 -s /bin/sh frontend

RUN yum clean all && \
    yum -y --enablerepo=osg-development --enablerepo=osg-upcoming install \
      git \
      condor \
      condor-classads \
      condor-procd \
      glideinwms-vofrontend-standalone \
      vo-client 

ADD image-config.d/*    /etc/osg/image-config.d/
ADD cron.d/*            /etc/cron.d/
ADD supervisor.d/*      /etc/supervisord.d/
ADD condor.d/*          /etc/condor/config.d/
