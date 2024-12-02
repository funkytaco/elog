#!/bin/bash

SERVICE_NAME="elog"
USER_NAME="ansibleusr"
PROJECT_DIR="/home/${USER_NAME}/git/apps/${SERVICE_NAME}"
SYSTEMD_DIR="/home/${USER_NAME}/.config/systemd/user"
SERVICE_FILE="${SYSTEMD_DIR}/${SERVICE_NAME}.service"
PODMAN_COMPOSE_PATH="/usr/bin/podman-compose"
INIT_SCRIPT="${PROJECT_DIR}/app_up.sh"
INIT_SHUTDOWN_SCRIPT="${PROJECT_DIR}/app_down.sh"
USER_ID=$(id -u)

mkdir -p ${SYSTEMD_DIR}

if [ -f "${SERVICE_FILE}" ]; then
    echo "Service file ${SERVICE_FILE} already exists. Aborting to prevent overwriting."
    exit 1
fi

# Create the ExecStart script for systemd
cat <<EOF > ${INIT_SCRIPT}
#!/bin/bash
SERVICE="$SERVICE_NAME"
export USER_ID=$USER_ID
cd ${PROJECT_DIR}
#echo "USER_ID=${USER_ID}" > .dev.env
USER_ID=$USER_ID podman-compose up
EOF

chmod +x ${INIT_SCRIPT}

# Create the ExecStop script for systemd
cat <<EOF > ${INIT_SHUTDOWN_SCRIPT}
#!/bin/bash
SERVICE_NAME="${SERVICE_NAME}"
export USER_ID=$USER_ID
cd ${PROJECT_DIR}
#echo "USER_ID=$USER_ID" > .dev.env
USER_ID=$USER_ID podman-compose down
EOF

chmod +x ${INIT_SHUTDOWN_SCRIPT}


# Create the service file
cat <<EOF > ${SERVICE_FILE}
[Unit]
Description=Podman Compose ${SERVICE_NAME^} Application
After=network-online.target
Wants=network-online.target

[Service]
Type=simple
ExecStart=${INIT_SCRIPT}
ExecStop=${INIT_SHUTDOWN_SCRIPT}
TimeoutStartSec=0
Restart=always
RestartSec=30

[Install]
WantedBy=default.target
EOF

systemctl --user daemon-reload
systemctl --user enable ${SERVICE_NAME}.service
systemctl --user start ${SERVICE_NAME}.service

loginctl enable-linger ${USER_NAME}

systemctl --user status ${SERVICE_NAME}.service --no-pager
    echo "--------------------------------"
    echo "  APP STATUS: $SERVICE_NAME"
    STATUS=$(systemctl --user is-active "$SERVICE_NAME")

    if [ "$STATUS" = "active" ]; then
        echo "$SERVICE_NAME is running."
    echo "--------------------------------"
    else
        echo "$SERVICE_NAME is not running. Check systemctl journal."
    echo "--------------------------------"
    fi
