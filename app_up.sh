#!/bin/bash
SERVICE="elog"
export USER_ID=1102
cd /home/ansibleusr/git/apps/elog
#echo "USER_ID=1102" > .dev.env
USER_ID=1102 podman-compose up
