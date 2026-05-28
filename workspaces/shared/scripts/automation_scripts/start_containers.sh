#!/bin/bash

if [ -z "$1" ]; then
  if [ -d "containers/workspaces" ]; then
    cd "containers/workspaces" || { echo "Failed to change directory to containers/workspaces"; exit 1; }
  else
    echo "Error: 'containers/workspaces' not found"
    exit 1
  fi
else
  cd "$1" || { echo "Directory not found: $1"; exit 1; }
fi

podman-compose up -d
