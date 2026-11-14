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
You need also a cloned version of this repository. At least the compose files in this directory.
```
cd /myworkdir
mkdir ws-test; cd ws-test
TEST_DIR=$(pwd)
git clone https://github.com/glideinWMS/containers.git
cd containers/workspaces
```

You have two options. To use the ITB setup with pre-installed workspaces (keep reading) or to use the [Testbed setup documented later in this document](#testbed-setup),
which is starting from bare-bone workspaces and installing GlideinWMS via the provided [install script](testbed-workspace/scripts/install-glideinwms.sh).

You can start the GlideinWMS ITB setup with the following commands.
The `IMAGE_NAMESPACE` variable is optional, allows to pick a different repository, you can use a local name or also a full path like `docker.io/USERNAME/IMAGE`; the `glideinwms` namespace is the default.
The `podman-compose up` command is inconsistent depending on versions. Usually it uses local images if available.
The compose file contains both the image path and the build instructions, so if the images are not available podman-compose, depending on its version, may prioritize building or downloading new images.
So use the up command with the `--no-build` option or the pull command to download all the images from the repository (e.g. glideinwms on Docker Hub) if you prefer so.

If you want to start from a clean slate, remove the locally available images:
```bash
podman rmi -a
```
If you want to download the images you have to pull them first:
```bash
IMAGE_NAMESPACE=docker.io/glideinwms podman-compose pull
```
If you want to build/rebuild all the images, including the gwms-workspace, and download only the small almalinux 9, use:
```bash
podman-compose -f compose-buildbase.yml build
```
Finally you can start (and build if needed) the main ITB images using the compose.yml file.
The `GMWS_PATH` variable points to a common directory, e.g. for the GWMS sources; it is optional, the directory is created if not existing, and a shared volume local to the containers is used if not passed (i.e. if GMWS_PATH is not defined).
```bash
# Assuming you are in the workspaces directory and TEST_DIR is defined from above
mkdir "$TEST_DIR"/gwms  # Optional, if you'd like to put something in it
GWMS_PATH="$TEST_DIR"/gwms/ podman-compose up -d
```

To bring down the ITB setup use `podman-compose down`.

Note that this ITB setup uses a local private virtual network, with outbound and no inbound connectivity. 
The domain is fictionary, `glideinwms.org`, but everything works because DNS, certificates and config files 
are configured consistently.
Do not use this setup connected to the open Internet. The CA certificate and key used to self-sign the ITB
host certificates are publicly available, anyone can generate new host certificates!
All the ITB containers are built for multiple architectures: x84_64 (for Intel or AMD processors) and aarch64 (for ARM processors like on M1 Macs).

You can also use different versions of the ITB images and containers.
E.g. to run with SL7 nodes:
```bash
IMAGE_NAMESPACE=docker.io/glideinwms IMAGE_LABEL=sl7_latest-20240717-0328 podman-compose pull
IMAGE_NAMESPACE=docker.io/glideinwms IMAGE_LABEL=sl7_latest-20240717-0328 GWMS_PATH=/myworkdir/ws-test/gwms/ podman-compose up -d
```

There are also a script to build locally all the GlideinWMS containers (the IMAGE_NAMESPACE variable is optional):
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

# To refresh the SciToken and submit new test jobs in the frontend-workspace:
/opt/scripts/create-scitoken.sh -r
/opt/scripts/run-test.sh
```

## To manually build SL7 or EL8 containers

The base workspace, gwms-workspace, has 3 different Dockerfiles: the default EL9 (AlmaLinux9), SL7 (RHEL7/ScientificLinux7), and EL8 (AlmaLinux8).
Each of them can be used as a base for the other workspaces (except the testbed) and the result will be images with different OSs.
For example, to have a EL8 CE:
```bash
export BUILD_DATE=$(date -u +'%Y-%m-%dT%H:%M:%SZ')
# Replace 'el8' with 'sl7' for a RHEL7 CE
export GWMS_VERSION=el8
podman build --build-arg BUILD_DATE=$BUILD_DATE -t glideinwms/gwms-workspace:$GWMS_VERSION -f gwms-workspace/Dockerfile.$GWMS_VERSION  .
podman build --build-arg BUILD_DATE=$BUILD_DATE --build-arg GWMS_VERSION=$GWMS_VERSION -t glideinwms/ce-workspace:$GWMS_VERSION  -f ce-workspace/Dockerfile .
```
Now you can use the image to add it to a running testbed as `el8ce-workspace.glideinwms.org`, the host name used in the provided Factory configuration.
You can start the CE manually or add it in a compose file with a section like:
```yaml
  el8ce-workspace:
    container_name: el8ce-workspace.glideinwms.org
    build:
      context: .
      arg:
        - GWMS_VERSION=el8
      cache_from:
        - ${IMAGE_NAMESPACE-glideinwms}/ce-workspace:el8
      dockerfile: ce-workspace/Dockerfile
    image: ${IMAGE_NAMESPACE-glideinwms}/ce-workspace:el8
    volumes:
      - ${GWMS_PATH-gwms-dev-local}:/opt/gwms
    networks:
      - gwms
    hostname: el8ce-workspace.glideinwms.org
    tty: true
    stdin_open: true
    stop_grace_period: 2s
```


## Testbed setup

The testbed defined via the `testbed-workspace` image and the `compose-testbed.yml` compose file start from a barebone OS image to test better the RPM installation of the system.
In this example we use `compose-wports.yml` to be able to also interact from outside and `IMAGE_NAMESPACE` to try to prioritize download (you may want to add also `--no-build` - see above).
```bash
export TEST_DIR=$HOME/ws-test
GWMS_PATH="$TEST_DIR"/gwms/ IMAGE_NAMESPACE=docker.io/glideinwms  BASE_COMPOSE=compose-testbed.yml podman-compose -f compose-wports.yml up -d
podman exec -it testbed-ce-workspace.glideinwms.org /opt/scripts/startup.sh
podman exec -it testbed-factory-workspace.glideinwms.org /opt/scripts/install-glideinwms.sh --logserver
podman exec -it testbed-frontend-workspace.glideinwms.org /opt/scripts/install-glideinwms.sh
```
The installation of the testbed machines is very minimal. To add some development tools you can use `install-developer.sh`, e.g.:
```bash
podman exec -it testbed-frontend-workspace.glideinwms.org install-developer.sh
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

If you want to customize the compose services have a look at the [compose specification](https://github.com/compose-spec/compose-spec/blob/main/00-overview.md).
To be able to apptainer inside a podman container, run (`podman run ...`) with options `--privileged  --device /dev/fuse`
or at least options `--security-opt seccomp=unconfined --security-opt systempaths=unconfined --security-opt no-new-privileges --device /dev/fuse`.
`/dev/fuse` is because of squashfs to read SIF files. You can use expanded images or `--unsquash` in apptainer to avoid that.

To run a podman container inside a container you can use `--privileged` or check one of the options [here](https://www.redhat.com/en/blog/podman-inside-container).
