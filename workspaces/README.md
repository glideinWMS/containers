<!--
SPDX-FileCopyrightText: 2020 Fermi Research Alliance, LLC
SPDX-License-Identifier: Apache-2.0
-->

# workspaces

Workspaces in containers designed for interactive use, inspired by [Alnoda](https://alnoda.org/) and similar projects.
These are RHEL based containers to provide a consistent development environment for GlideinWMS and Decision Engine.
They are not separating or isolating the different services to improve performance and security, so they are meant only
for a protected development environment, not for production.
For production use instead the frontend and factory off the containers root folder.

The current development environment is based on EL9 and Python 3.9.

Some notable tools used in these containers:

-   [Supervisor](http://supervisord.org/) since [systemd and similars don't work so well in containers](https://docs.docker.com/config/containers/multi-service_container/)
-   [Docker systemctl replacement](https://github.com/gdraheim/docker-systemctl-replacement) that allows to run most systemctl commands also without systemd

## Use

To use the containers you need docker or podman (recommended).
You can start the GlideinWMS ITB setup with (IMAGE_NAMESPACE is optional, the glideinwms namespace is the default, 
you can use local or also a full path like `docker.io/USERNAME/IMAGE`; 
GMWS_PATH is optional, is created if not existing, and a local volume is used if not passed):
```bash
GMWS_PATH=/root/ws-test/gwms/ IMAGE_NAMESPACE=glideinwms podman-compose up -d
```
and bring it down with `podman-compose down`.

Note that this ITB setup uses a local private virtual network, with outbound and no inbound connectivity. 
The domain is fictionary, `glideinwms.org`, but everything works because DNS, certificates and config files 
are configured consistently.
Do not use this setup connected to the open Internet. The CA certificate and key used to self-sign the ITB
host certificates are publicly available, anyone can generate new host certificates!

If you changed the containers or prefer a local build, 
you can also build all the GlideinWMS containers with (the IMAGE_NAMESPACE variable is optional):
```bash
IMAGE_NAMESPACE=glideinwms ./build-all.sh
# or
IMAGE_NAMESPACE=glideinwms podman-compose build -f compose-buildbase.yml
IMAGE_NAMESPACE=glideinwms podman-compose build
```

Other useful commands:
```bash
podman ps -a
podman images
podman exec -it ce-workspace.glideinwms.org /bin/bash
podman exec -it factory-workspace.glideinwms.org /bin/bash
podman exec -it frontend-workspace.glideinwms.org /bin/bash
```
