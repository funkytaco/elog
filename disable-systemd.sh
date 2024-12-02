#!/bin/bash
SERVICE_NAME="elog"
USER_NAME="ansibleusr"
SYSTEMD_DIR="/home/${USER_NAME}/.config/systemd/user"
SERVICE_FILE="${SYSTEMD_DIR}/${SERVICE_NAME}.service"

if [ -f "${SERVICE_FILE}" ]; then
    echo "Disabling the service ${SERVICE_NAME}..."
    systemctl --user disable "${SERVICE_NAME}"
    echo "Service ${SERVICE_NAME} disabled."
    rm -f ${SERVICE_FILE}
else
    echo "Service file ${SERVICE_FILE} does not exist. Nothing to disable."
fi
