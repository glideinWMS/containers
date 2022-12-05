FROM opensciencegrid/software-base:3.6-el7-release-20220728-2056
LABEL maintainer OSG Software <help@opensciencegrid.org>

# Create the frontend user with a fixed GID/UID
# This is important so that we can use the same IDs in the persistent volume used for
# the web-area
RUN groupadd -o -g 993 frontend
RUN useradd -o -u 996 -g 993 -s /bin/sh -d /var/lib/gwms-frontend frontend
RUN mkdir -p /var/lib/gwms-frontend/.condor/tokens.d && \
    chown -R frontend.frontend /var/lib/gwms-frontend/.condor

RUN yum clean all && \
    yum -y --enablerepo=osg-development install \
      patch \
      git \
      condor \
      condor-classads \
      condor-procd \
      glideinwms-vofrontend-standalone \
      vo-client \
      htgettoken

COPY image-config.d/*    /etc/osg/image-config.d/
COPY cron.d/*            /etc/cron.d/
COPY supervisor.d/*      /etc/supervisord.d/
COPY condor.d/*          /etc/condor/config.d/

# we don't want the frontend password in the image layer since then it's the same for all deployments
RUN rm /etc/condor/passwords.d/FRONTEND /var/lib/gwms-frontend/passwords.d/FRONTEND
