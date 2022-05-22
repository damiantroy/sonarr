# Base
FROM docker.io/rockylinux/rockylinux:8
LABEL maintainer="Damian Troy <github@black.hole.com.au>"

# https://github.com/rocky-linux/sig-cloud-instance-images/issues/22
RUN chmod 1777 /tmp

RUN dnf -y update && dnf clean all

# Common
ENV PUID=1001
ENV PGID=1001
RUN groupadd -g "$PGID" videos && \
    useradd --no-log-init -u "$PUID" -g videos -d /config -M videos && \
    install -d -m 0755 -o videos -g videos /config /videos
ENV TZ=Australia/Melbourne
ENV LANG=C.UTF-8
COPY test.sh /usr/local/bin/

# App
RUN dnf -y install dnf-plugins-core epel-release && \
    dnf -y localinstall --nogpgcheck https://mirrors.rpmfusion.org/free/el/rpmfusion-free-release-8.noarch.rpm https://mirrors.rpmfusion.org/nonfree/el/rpmfusion-nonfree-release-8.noarch.rpm && \
    dnf config-manager --add-repo https://download.mono-project.com/repo/centos8-stable.repo && \
    (dnf config-manager --set-enabled PowerTools || dnf config-manager --set-enabled powertools) && \
    dnf -y install nmap-ncat wget mediainfo libzen libmediainfo curl gettext mono-core mono-devel sqlite.x86_64 git par2cmdline p7zip unrar unzip tar gcc libxslt-devel yum-utils python3-feedparser python3-configobj python3-cheetah python3-dbus python3-devel && \
    dnf clean all
RUN wget -O /tmp/NzbDrone.master.tar.gz http://update.sonarr.tv/v2/master/mono/NzbDrone.master.tar.gz && \
    tar -xvf /tmp/NzbDrone.master.tar.gz -C /opt/ && \
    rm -f /tmp/NzbDrone.master.tar.gz && \
    mkdir -p /opt/sonarr && \
    mv /opt/NzbDrone /opt/sonarr/bin && \
    rm -rf /opt/NzbDrone && \
    chown -R "$PUID:$PGID" /opt/sonarr

# Runtime
VOLUME /config /videos
EXPOSE 8989
USER videos
CMD ["/usr/bin/mono","/opt/sonarr/bin/NzbDrone.exe","-nobrowser","-data","/opt/sonarr"]
