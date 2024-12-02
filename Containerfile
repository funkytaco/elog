FROM registry.redhat.io/ubi8/ubi #or minimal

ADD _build .
#COPY _build/configs/automationhub-root.crt /usr/share/pki/ca-trust-source/anchors
#RUN update-ca-trust

#the following is for migrating data from a different server. not needed for new install
#COPY _build/configs/elogd-custom.cfg /usr/local/elog/elogd-custom.cfg
#COPY _build/logbooks/ /usr/local/elog/logbooks/
#COPY _build/themes/ /usr/local/elog/themes/
#COPY _build/images/ /usr/local/elog/images/

# Install EPEL and ImageMagick
RUN dnf install -y epel-release &&     dnf install -y ImageMagick &&     dnf clean all


COPY _build/rpms/elog-3.1.5-20240226.el8.x86_64.rpm /var/tmp/
RUN rpm -ivh /var/tmp/elog-3.1.5-20240226.el8.x86_64.rpm

RUN mkdir -p /var/log/elog &&     chmod 755 /var/log/elog

EXPOSE 8080

CMD ["/usr/local/sbin/elogd", "-c", "/etc/elog/elogd.cfg", "-p", "8080"]