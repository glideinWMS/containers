FROM opensciencegrid/software-base:fresh
LABEL maintainer OSG Software <help@opensciencegrid.org>

# Create the frontend user with a fixed GID/UID
# This is important so that we can use the same IDs in the persistent volume used for
# the web-area
RUN groupadd -o -g 993 frontend
RUN useradd -o -u 996 -g 993 -s /bin/sh frontend

# ddavila 20210331:
# 3.9.1 is only available in develpment at the moment
RUN yum -y --enablerepo=osg-development --enablerepo=osg-upcoming install glideinwms-vofrontend-standalone

RUN yum -y install vo-client \
    git

ADD image-config.d/*    /etc/osg/image-config.d/
ADD cron.d/*            /etc/cron.d/
ADD supervisor.d/*      /etc/supervisord.d/
ADD condor.d/*          /etc/condor/config.d/
