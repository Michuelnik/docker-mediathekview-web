# Pull base image.
FROM jlesage/baseimage-gui:debian-10-v4

ENV USER_ID=0 GROUP_ID=0 TERM=xterm

ARG MEDIATHEK_VERSION=14.1.0

# Refresh apt cache
RUN apt-get update \
    && apt-get upgrade -y

# Locale needed for storing files with umlaut
RUN apt-get install -y apt-utils locales \
    && echo en_US.UTF-8 UTF-8 > /etc/locale.gen \
    && locale-gen

ENV LC_ALL=en_US.UTF-8
ENV LANGUAGE=en_US.UTF-8
ENV LANG=en_US.UTF-8

# Runtime deps
RUN apt-get install -y \
        wget \
	procps \
        vlc \
        flvstreamer \
        ffmpeg \
    && rm -rf /var/lib/apt/lists/*

# Maximize only the main/initial window.
COPY src/main-window-selection.xml /etc/openbox/main-window-selection.xml

# Set environment variables.
ENV APP_NAME="Mediathekview" \
    S6_KILL_GRACETIME=8000

# Define mountable directories.
VOLUME ["/config"]
VOLUME ["/output"]

# Metadata.
LABEL \
      org.label-schema.name="mediathekview" \
      org.label-schema.description="Docker container for Mediathekview" \
      org.label-schema.version=$MEDIATHEK_VERSION \
      org.label-schema.vcs-url="https://github.com/Michuelnik/docker-mediathekview-web" \
      org.label-schema.schema-version="1.0"

ENV APP_VERSION=$MEDIATHEK_VERSION
ARG DOCKER_IMAGE_VERSION=
ENV DOCKER_IMAGE_VERSION=$DOCKER_IMAGE_VERSION

# Define software download URLs.
ARG MEDIATHEKVIEW_URL=https://download.mediathekview.de/stabil/MediathekView-$MEDIATHEK_VERSION-linux.tar.gz

# download Mediathekview
RUN mkdir -p /opt/MediathekView \
    && wget -q ${MEDIATHEKVIEW_URL} -O - \
    | tar xzv -C /opt


COPY src/startapp.sh /startapp.sh
