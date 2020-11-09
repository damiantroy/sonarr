# Base
FROM centos:7
LABEL maintainer="Damian Troy <github@black.hole.com.au>"
RUN yum -y update && yum clean all

# Common
VOLUME /config
ENV PUID=1001
ENV PGID=1001
RUN groupadd -g ${PGID} videos && \
    useradd --no-log-init -u ${PUID} -g videos -d /config -M videos && \
    install -d -m 0755 -o videos -g videos /config /videos
ENV TZ=Australia/Melbourne
COPY test.sh /usr/local/bin/

# App
VOLUME /videos
EXPOSE 8989
RUN rpm --import "http://keyserver.ubuntu.com/pks/lookup?op=get&search=0x3FA7E0328081BFF6A14DA29AA6A19B38D3D831EF" && \
    yum -y install yum-utils epel-release http://repository.it4i.cz/mirrors/repoforge/redhat/el7/en/x86_64/rpmforge/RPMS/rpmforge-release-0.5.3-1.el7.rf.x86_64.rpm && \
    yum-config-manager --add-repo http://download.mono-project.com/repo/centos/ && \
    yum -y install nmap-ncat git wget curl tar gcc unzip unrar p7zip mediainfo libzen libmediainfo gettext mono-core mono-devel sqlite.x86_64 par2cmdline python-feedparser python-configobj python-cheetah python-dbus python-devel libxslt-devel && \
    yum clean all
RUN wget -O /tmp/NzbDrone.master.tar.gz http://update.sonarr.tv/v2/master/mono/NzbDrone.master.tar.gz && \
    tar xzf /tmp/NzbDrone.master.tar.gz -C /opt/ && \
    rm -f /tmp/NzbDrone.master.tar.gz && \
    mkdir /opt/sonarr && \
    mv /opt/NzbDrone /opt/sonarr/bin && \
    chown -R ${PUID}:${PGID} /opt/sonarr

# Runtime
USER videos
CMD ["/usr/bin/mono","/opt/sonarr/bin/NzbDrone.exe","-nobrowser","-data","/opt/sonarr"]

