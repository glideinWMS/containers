#!/bin/bash

# SPDX-FileCopyrightText: 2020 Fermi Research Alliance, LLC
# SPDX-License-Identifier: Apache-2.0

# Using IMAGE_NAMESPACE
[[ -z "${IMAGE_NAMESPACE}" ]] && IMAGE_NAMESPACE=glideinwms || true
[[ "$IMAGE_NAMESPACE" = NONE ]] && IMAGE_NAMESPACE= || true
MY_NAMESPACE=
[[ -n "$IMAGE_NAMESPACE" ]] && MY_NAMESPACE="${IMAGE_NAMESPACE%/}/" || true
# Exporting IMAGE_NAMESPACE for Dockerfiles
export IMAGE_NAMESPACE
export BUILD_DATE=$(date -u +'%Y-%m-%dT%H:%M:%SZ')

# Building for the local architecture
podman build --build-arg BUILD_DATE=$BUILD_DATE -t "$MY_NAMESPACE"gwms-workspace -f gwms-workspace/Dockerfile  .
podman build --build-arg BUILD_DATE=$BUILD_DATE -t "$MY_NAMESPACE"ce-workspace -f ce-workspace/Dockerfile .
podman build --build-arg BUILD_DATE=$BUILD_DATE -t "$MY_NAMESPACE"factory-workspace -f factory-workspace/Dockerfile .
podman build --build-arg BUILD_DATE=$BUILD_DATE -t "$MY_NAMESPACE"frontend-workspace -f frontend-workspace/Dockerfile .
