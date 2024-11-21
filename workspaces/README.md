<!--
SPDX-FileCopyrightText: 2020 Fermi Research Alliance, LLC
SPDX-License-Identifier: Apache-2.0
-->

# Workspaces

Workspaces in containers designed for interactive use, inspired by [Alnoda](https://alnoda.org/) and similar projects.
These are RHEL based containers to provide a consistent development environment for GlideinWMS and Decision Engine.
They are not separating or isolating the different services to improve performance and security, so they are meant only
for a protected development environment, not for production.
For production use instead the frontend and factory off the containers root folder.

The current development environment is based on EL9 and Python 3.9.
Images on Docker Hub glideinwms organization are multi-platform (linux/amd64, linux/arm64) to allow seamless development also on M1 Macs.

Some notable tools used in these containers:

-   [Supervisor](http://supervisord.org/) since [systemd and similars don't work so well in containers](https://docs.docker.com/config/containers/multi-service_container/)
-   [Docker systemctl replacement](https://github.com/gdraheim/docker-systemctl-replacement) that allows to run most systemctl commands also without systemd

## Use

To use the containers you need docker or podman (recommended).
You need also a cloned version of this repository. At least the conpose files in this direcotry.
```
cd /myworkdir
mkdir ws-test; cd ws-test
TEST_DIR=$(pwd)
git clone https://github.com/glideinWMS/containers.git
cd containers/workspaces
```
Then you can start the GlideinWMS ITB setup with the following commands.
`IMAGE_NAMESPACE` is optional, allows to pick a different repository, you can use local or also a full path like `docker.io/USERNAME/IMAGE`, `glideinwms` namespace is the default.
`podman-compose up` builds unavailable images, so use the pull command to download the all the images from the repository (e.g. glideinwms on Docker Hub) if you prefer so:
```bash
IMAGE_NAMESPACE=docker.io/glideinwms podman-compose pull
```
If you want to build all the images, including gwms-workspace, and download only the small almalinux 9, use:
```bash
podman-compose -f compose-buildbase.yml build
```
And then start (and build if needed) the main images using the compose.yml file.
`GMWS_PATH` is a common directory, e.g. for the GWMS sources; it is optional, the directory is created if not existing, and a local shared volume is used if not passed.
```bash
# Assuming you are in the workspaces directory and TEST_DIR is defined from above
mkdir "$TEST_DIR"/gwms  # Optional, if you'd like to put something in it
GWMS_PATH="$TEST_DIR"/gwms/ podman-compose up -d
```
and bring it down with `podman-compose down`.

Note that this ITB setup uses a local private virtual network, with outbound and no inbound connectivity. 
The domain is fictionary, `glideinwms.org`, but everything works because DNS, certificates and config files 
are configured consistently.
Do not use this setup connected to the open Internet. The CA certificate and key used to self-sign the ITB
host certificates are publicly available, anyone can generate new host certificates!

You can also use different versions of the ITB images and containers.
E.g. to run with SL7 nodes:
```commandline
IMAGE_NAMESPACE=docker.io/glideinwms IMAGE_LABEL=sl7_latest-20240717-0328 podman-compose pull
IMAGE_NAMESPACE=docker.io/glideinwms IMAGE_LABEL=sl7_latest-20240717-0328 GWMS_PATH=/myworkdir/ws-test/gwms/ podman-compose up -d
```

There are also also a script build locally all the GlideinWMS containers (the IMAGE_NAMESPACE variable is optional):
```bash
IMAGE_NAMESPACE=glideinwms ./build-all.sh
```
and one to pull or re-tag images:
```bash
./pull-all.sh -vt -s sl7_latest-20240717-0328 -d sl7_latest
```

Other useful commands:
```bash
podman ps -a
podman images
podman exec -it ce-workspace.glideinwms.org /opt/scripts/startup.sh
podman exec -it factory-workspace.glideinwms.org /opt/scripts/startup.sh
podman exec -it frontend-workspace.glideinwms.org /opt/scripts/startup.sh
# Remember to authenticate at the URL to validate the SciToken! 
podman exec -it frontend-workspace.glideinwms.org /opt/scripts/run-test.sh

podman exec -it ce-workspace.glideinwms.org /bin/bash
podman exec -it factory-workspace.glideinwms.org /bin/bash
podman exec -it frontend-workspace.glideinwms.org /bin/bash
```

## Troubleshooting

If docker/podman-compose makes a local volume for factory-workspace and frontend-workspace instead of mounting your GWMS_PATH directory, check that you spelled correctly "GWMS_PATH", like in the compose.yml file.
We had a miss-spell in an older compose.yml causing trouble.

Sometimes old images are picked instead of downloading from Docker Hub.
You need to cleanup to download the new images:
```bash
# Cleanup all running containers
podman rm $(podman stop $(podman ps -q))
# To cleanup old images
podman image list
podman image rm $(podman image list -q)
# Some may need to be removed with -f
```
