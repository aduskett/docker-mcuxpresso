FROM centos:8
LABEL maintainer="Adam Duskett <aduskett@gmail.com>" \
description="Everything needed to run MCUExpresso in a docker container with X11 forwarding."

ARG IDE_VERSION
ARG USERNAME
ARG UID
ARG GID

COPY ./mcuxpressoide-${IDE_VERSION}.x86_64.deb.bin /tmp


RUN set -e; \
  dnf update -y; \
  dnf install -y epel-release; \
  dnf install -y dnf-plugins-core; \
  dnf config-manager --set-enabled powertools; \
  dnf install -y \
  diffutils \
  dpkg \
  git \
  java-11-openjdk \
  libcanberra \
  libcanberra-gtk3 \
  libusb-devel \
  ncurses-compat-libs \
  PackageKit-gtk3-module \
  webkit2gtk3 \
  wget \
  which; \
  wget http://rpmfind.net/linux/fedora/linux/releases/33/Everything/x86_64/os/Packages/d/dfu-util-0.9-10.fc33.x86_64.rpm -O /tmp/dfu.rpm; \
  dnf install -y /tmp/dfu.rpm; \
  rm -f /tmp/dfcu.rpm; \
  useradd -ms /bin/bash -u ${UID} -g ${GID} ${USERNAME}; \
  usermod -aG wheel ${USERNAME}; \
  mkdir -p /home/${USERNAME} ; \
  echo "alias ls='ls --color=auto'" >> /home/${USERNAME}/.bashrc; \
  echo "PS1='\u@\H [\w]$ '" >> /home/${USERNAME}/.bashrc; \
  chown -R ${USERNAME}:${USERNAME} /home/${USERNAME};

RUN set -e; \
  cd /tmp/; \
  mkdir -p /tmp/mcu/; \
  chmod a+x ./mcuxpressoide-${IDE_VERSION}.x86_64.deb.bin; \
  ./mcuxpressoide-${IDE_VERSION}.x86_64.deb.bin --noexec --target /tmp/mcu; \
  cd /tmp/mcu; \
  dpkg --force-depends -i ./JLink_Linux_x86_64.deb; \
  dpkg --unpack mcuxpressoide-${IDE_VERSION}.x86_64.deb; \
  rm -f /var/lib/dpkg/info/mcuxpressoide.postinst; \
  dpkg --force-depends --configure mcuxpressoide; \
  mkdir -p /usr/share/NXPLPCXpresso; \
  chmod a+w /usr/share/NXPLPCXpresso; \
  ln -s /usr/local/mcuxpressoide-${IDE_VERSION} /usr/local/mcuxpressoide; \
  ln -sf /usr/local/mcuxpressoide-${IDE_VERSION}/ide/mcuxpressoide /usr/bin/mcuxpressoide; \
  rm -rf /tmp/mcuxpressoide-${IDE_VERSION}.x86_64.deb.bin; \
  rm -rf /tmp/mcu;

USER ${USERNAME}
CMD ["/usr/bin/mcuxpressoide"]
