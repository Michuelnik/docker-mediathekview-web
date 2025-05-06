# Pull base image.
FROM jlesage/baseimage-gui:debian-10-v4

ARG MEDIATHEK_VERSION=14.2.0 \
    DOCKER_IMAGE_VERSION=1 \
    MEDIATHEKVIEW_URL=https://download.mediathekview.de/stabil/MediathekView-$MEDIATHEK_VERSION-linux.tar.gz

# Set environment variables
ENV APP_NAME="Mediathekview" \
    APP_VERSION=$MEDIATHEK_VERSION \
    DOCKER_IMAGE_VERSION=$DOCKER_IMAGE_VERSION \
    \
    USER_ID=0 \
    GROUP_ID=0 \
    \
    LC_ALL=en_US.UTF-8 \
    LANGUAGE=en_US.UTF-8 \
    LANG=en_US.UTF-8 \
    \
    TERM=xterm \
    S6_KILL_GRACETIME=8000

# Locale needed for storing files with umlaut
RUN apt-get update \
    && apt-get upgrade -y \
    && apt-get install -y --no-install-recommends \
        apt-utils locales \
        wget \
        procps \
        flvstreamer \
    && apt-get install -y \
        ffmpeg \
        vlc \
    && rm -rf /var/cache/apt/archives /var/lib/apt/lists/* /var/log/apt/* /var/log/dpkg.log

RUN echo en_US.UTF-8 UTF-8 > /etc/locale.gen \
    && locale-gen

# Metadata.
LABEL \
      org.label-schema.name="mediathekview" \
      org.label-schema.description="Docker container for Mediathekview" \
      org.label-schema.version=$MEDIATHEK_VERSION \
      org.label-schema.vcs-url="https://github.com/Michuelnik/docker-mediathekview-web" \
      org.label-schema.schema-version="1.0"

# download Mediathekview
RUN mkdir -p /opt/MediathekView \
    && wget --no-verbose -O - \
        ${MEDIATHEKVIEW_URL} \
    | tar xz -C /opt

# install MediathekView logo as app icon
COPY contrib/MediathekView.png /tmp
RUN install_app_icon.sh /tmp/MediathekView.png \
    && rm -rf /var/cache/apt/archives /var/lib/apt/lists/* /var/log/apt/* /var/log/dpkg.log

# Maximize only the main/initial window.
COPY src/main-window-selection.xml /etc/openbox/main-window-selection.xml

COPY src/startapp.sh /startapp.sh
