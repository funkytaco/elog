#!/bin/bash
RPM_VERSION='3.1.5-20240226'
REGISTRY="registry.redhat.io"
REGISTRY_URI="${REGISTRY}/ubi8/ubi"
IMAGE_NAME="elog"
INTERNAL_REGISTRY_URI="myregistry" #uncomment push commands

podman login $REGISTRY
podman pull $REGISTRY/ubi8/ubi


cat <<EOF > Containerfile
FROM ${REGISTRY}/ubi8/ubi

#ADD _build .
#COPY _build/configs/automationhub-root.crt /usr/share/pki/ca-trust-source/anchors
#RUN update-ca-trust

#the following is for migrating data from a different server. not needed for new install
#COPY _build/configs/elogd-opensystems.cfg /usr/local/elog/elogd-opensystems.cfg
#COPY _build/logbooks/ /usr/local/elog/logbooks/
#COPY _build/themes/ /usr/local/elog/themes/
#COPY _build/images/ /usr/local/elog/images/

# Install EPEL and ImageMagick
RUN dnf install -y epel-release && \
    dnf install -y ImageMagick && \
    dnf clean all


COPY _build/rpms/elog-${RPM_VERSION}.el8.x86_64.rpm /var/tmp/
RUN rpm -ivh /var/tmp/elog-${RPM_VERSION}.el8.x86_64.rpm

RUN mkdir -p /var/log/elog && \
    chmod 755 /var/log/elog

EXPOSE 8080

CMD ["/usr/local/sbin/elogd", "-c", "/etc/elog/elogd.cfg", "-p", "8080"]
EOF
#The above are just defaults. Some CMD settings are overridden when you use the podman-compose.yml


# Build the image
podman build -t ${IMAGE_NAME} .
#note: you may need to adjust podman-compose.yaml to use the right tag
# Tag and push the latest version
# podman tag ${IMAGE_NAME} ${REGISTRY_URI}:latest
# podman push ${REGISTRY_URI}:latest

# # Tag and push the specific RPM version
# podman tag ${IMAGE_NAME} ${REGISTRY_URI}:${RPM_VERSION}
# podman push ${REGISTRY_URI}:${RPM_VERSION}

