FROM ghcr.io/linuxserver/baseimage-kasmvnc:debianbookworm

# set version label
ARG BUILD_DATE
ARG VERSION
ARG RAWTHERAPEE_VERSION
LABEL build_version="Linuxserver.io version:- ${VERSION} Build-date:- ${BUILD_DATE}"
LABEL maintainer="aptalca"

# title
ENV TITLE=RawTherapee 

RUN \
  echo "**** add icon ****" && \
  curl -o \
    /kclient/public/icon.png \
    https://raw.githubusercontent.com/linuxserver/docker-templates/master/linuxserver.io/img/rawtherapee-logo.png && \
  echo "**** install packages ****" && \
  apt-get update && \
  DEBIAN_FRONTEND=noninteractive \
  apt-get install --no-install-recommends -y \
    libatk1.0-0 \
    libatk-bridge2.0-0 \
    libgtk-3-0 && \
  echo "**** install rawtherapee from appimage ****" && \
  if [ -z ${RAWTHERAPEE_VERSION+x} ]; then \
    RAWTHERAPEE_VERSION=$(curl -sX GET "https://api.github.com/repos/beep6581/rawtherapee/releases/latest" \
    | awk '/tag_name/{print $4;exit}' FS='[""]'); \
  fi && \
  cd /tmp && \
  curl -o \
    /tmp/rawtherapee.app -L \
    "https://github.com/beep6581/rawtherapee/releases/download/${RAWTHERAPEE_VERSION}/RawTherapee_${RAWTHERAPEE_VERSION}_release.AppImage" && \
  chmod +x /tmp/rawtherapee.app && \
  ./rawtherapee.app --appimage-extract && \
  mv squashfs-root /opt/rawtherapee && \
  find /opt/rawtherapee -type d -exec chmod go+rx {} + && \
  cp \
    /opt/rawtherapee/usr/share/icons/hicolor/scalable/apps/rawtherapee.svg \
    /usr/share/icons/hicolor/scalable/apps/rawtherapee.svg && \
  echo "**** cleanup ****" && \
  apt-get autoclean && \
  rm -rf \
    /config/.cache \
    /var/lib/apt/lists/* \
    /var/tmp/* \
    /tmp/*

# add local files
COPY /root /

# ports and volumes
EXPOSE 3000
VOLUME /config
