#!/bin/bash

# SPDX-FileCopyrightText: 2020 Fermi Research Alliance, LLC
# SPDX-License-Identifier: Apache-2.0

# Using IMAGE_NAMESPACE and MY_LABEL
[[ -z "${IMAGE_NAMESPACE}" ]] && IMAGE_NAMESPACE=glideinwms || true
[[ "$IMAGE_NAMESPACE" = NONE ]] && IMAGE_NAMESPACE= || true
IMG_LIST_DEFAULT="ce,factory,frontend"
IMG_LIST_ALL="gwms,ce,factory,frontend,decisionengine,testbed,build"

help_msg() {
    cat << EOF
$0 [options] 
Pull ITB images (ce, factory, and frontend) and optionally re-tag them and the gwms base
  -h       print this message
  -v       verbose mode
  -b       OK to build if the download (pull) failed
  -t       re-tag images and push to docker hub (login before running this)
  -s SRC_LABEL image label (default: env IMAGE_LABEL)
  -d DST_LABEL new label for re-tagging
  -n NAMESPACE image namespace (e.g. docker.io/glideinwms, default: env IMAGE_NAMESPACE)
  -a       pull/build all images ($IMG_LIST_ALL)
  -i IMG_LIST comma separated list (no spaces) of images to pull or re-tag (default: $IMG_LIST_DEFAULT all when re-tagging)
              possible images keywords: $IMG_LIST_ALL
EOF
}

VERBOSE=
DO_BUILD=
DO_RETAG=
DST_LABEL=
IMG_LIST=
while getopts "vbtas:d:n:i:h" option
do
  case "${option}"
    in
    h) help_msg; exit 0;;
    b) DO_BUILD=yes;;
    v) VERBOSE=yes;;
    t) DO_RETAG=yes;;
    a) IMG_LIST="$IMG_LIST_ALL";;
    s) IMAGE_LABEL=$OPTARG;;
    d) DST_LABEL=":${OPTARG#:}";;
    n) IMAGE_NAMESPACE=$OPTARG;;
    i) IMG_LIST="$OPTARG";;
    *) echo "ERROR: Invalid option"; help_msg; exit 1;;
  esac
done

MY_NAMESPACE=
MY_LABEL=
[[ -n "$IMAGE_NAMESPACE" ]] && MY_NAMESPACE="${IMAGE_NAMESPACE%/}/" || true
[[ -n "$IMAGE_LABEL" ]] && MY_LABEL=":${IMAGE_LABEL#:}" || true
if [[ -z "$IMG_LIST" ]]; then
    [[ -n "$DO_RETAG" ]] && IMG_LIST="$IMG_LIST_ALL" || IMG_LIST="$IMG_LIST_DEFAULT"
fi

# Pulling for the local architecture
#podman pull "$MY_NAMESPACE"gwms-workspace"$MY_LABEL"
#podman pull "$MY_NAMESPACE"ce-workspace"$MY_LABEL"
#podman pull "$MY_NAMESPACE"factory-workspace"$MY_LABEL"
#podman pull "$MY_NAMESPACE"frontend-workspace"$MY_LABEL"

image_list=
if [[ -n "$IMG_LIST" ]]; then
    for i in ${IMG_LIST_ALL//,/ } ; do
        [[ ",${IMG_LIST}," = *,${i},* ]] && image_list="${image_list} ${i}-workspace" || true
    done
fi

for i in ${image_list} ; do
    to_pull="${MY_NAMESPACE}${i}${MY_LABEL}"
    [[ -n "$VERBOSE" ]] && echo "Pulling $to_pull" || true
    image_ok=false
    if podman pull "${to_pull}" ; then
        image_ok=true
    else
        # failed pull, build if OK to build
        if [[ -n "$DO_BUILD" ]]; then
            [[ -n "$VERBOSE" ]] && echo "Pull failed, building ${i}" || true
            # Exporting IMAGE_NAMESPACE for Dockerfiles
            export IMAGE_NAMESPACE
            BUILD_DATE=$(date -u +'%Y-%m-%dT%H:%M:%SZ')
            export BUILD_DATE
            # Building for the local architecture
            podman build --build-arg BUILD_DATE="$BUILD_DATE" -t "${to_pull}" -f "${i}"/Dockerfile  . && image_ok=true
        fi
    fi
    if [[ -n "$DO_RETAG" ]]; then
        if $image_ok ; then
            # Download or build were successful 
            [[ -n "$VERBOSE" ]] && echo "Re-tagging to ${MY_NAMESPACE}${i}${DST_LABEL} and pushing" || true
            podman tag "$to_pull" "${MY_NAMESPACE}${i}${DST_LABEL}"
            podman push "${MY_NAMESPACE}${i}${DST_LABEL}"
        else
            [[ -n "$VERBOSE" ]] && echo "Download/build failed. Skipping re-tagging and push for ${MY_NAMESPACE}${i}${DST_LABEL}"
        fi 
    fi
done
