#!/bin/bash

# Apply patches on /etc/osg/patches/
# it assumes all patches use absolute paths

if [ -e /etc/osg/patches ];then
  cd /etc/osg/patches

  for patch in `ls`; do
    echo "applying patch $patch"
    patch -d/ -p0 < $patch
  done

fi
