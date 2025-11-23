#!/bin/bash

# SPDX-FileCopyrightText: 2020 Fermi Research Alliance, LLC
# SPDX-License-Identifier: Apache-2.0

# Download and install apptainer and download the small alpine test image

CONTAINERS_DIR=/opt/containers

if ! cd "$CONTAINERS_DIR"; then
    echo "Containers directory ($CONTAINERS_DIR) missing. Aborting."
    exit 1
fi
if ! curl -s https://raw.githubusercontent.com/apptainer/apptainer/main/tools/install-unprivileged.sh | \
    bash -s - "$CONTAINERS_DIR"/apptainer ; then
  echo "Failed to install Apptainer. Aborting."
  exit 2
fi
container_uri="oras://ghcr.io/apptainer/alpine:latest"
if [[ "$(uname -m)" =~ ^(arm64|aarch64)$ ]]; then
    container_uri="oras://ghcr.io/apptainer/alpine:latest-arm64"
fi
if ! /opt/containers/apptainer/bin/apptainer pull alpine.sif "$container_uri" ; then
    echo "Failed to download the Alpine test image ($container_uri) on $(uname -m)."
    exit 3
fi
echo "APPTAINER_TEST_IMAGE=$CONTAINERS_DIR/alpine.sif" >> /etc/environment
# Cleanup and messages
rm -rf "$HOME"/.apptainer || true  # Removing apptainer caches
cat << EOF
Downloaded Apptainer in $CONTAINERS_DIR/apptainer/bin/apptainer
Downloaded test container ($container_uri) as $CONTAINERS_DIR/alpine.sif
Added APPTAINER_TEST_IMAGE to the environment
EOF
