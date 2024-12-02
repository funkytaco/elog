#!/bin/bash
APPNAME='elog'
echo Inspecting Mounts for ${APPNAME}
podman inspect -f '{{.Mounts}}' $APPNAME
