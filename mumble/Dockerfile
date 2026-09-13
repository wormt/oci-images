# SPDX-License-Identifier: WTFPL
ARG BASE_IMAGE=alpine:3.22.2
ARG MUMBLE_BUILD_NUMBER=735
ARG MUMBLE_VERSION=1.5.$MUMBLE_BUILD_NUMBER

FROM $BASE_IMAGE as base
RUN apk -v --no-cache update; \
  apk -v --no-cache upgrade -la; \
  apk -v --no-cache add \
  ca-certificates \
  libcap2 \
  qt5-qtbase-sqlite \
  libprotobuf \
  abseil-cpp-die-if-null \
  abseil-cpp-flags-marshalling \
  libstdc++

RUN update-ca-certificates


FROM base as builder
ARG MUMBLE_BUILD_NUMBER MUMBLE_VERSION
ARG TGZ=mumble-$MUMBLE_VERSION.tar.gz

RUN apk -v --no-cache add \
  tar \
  cmake \
  samurai \
  make \
  gcc \
  g++ \
  python3 \
  binutils \
  build-base \
  musl-dev \
  boost-dev \
  libcap-dev \
  openssl-dev>3 \
  opus-dev \
  poco-dev \
  protobuf-dev \
  qt5-qtbase-dev \
  qt5-qtsvg-dev \
  qt5-qttools-dev

ADD --checksum=sha256:db8990079f556a877218d471bcf2c24eb5e4520b652f3c20793d0aadedaae6ae \
  https://github.com/mumble-voip/mumble/releases/download/v$MUMBLE_VERSION/$TGZ /tmp/
RUN tar xf /tmp/$TGZ -C /tmp && \
  mv /tmp/mumble-$MUMBLE_VERSION /tmp/mumble
WORKDIR /tmp/mumble

RUN cmake -B build -G Ninja \
  -DCMAKE_BUILD_TYPE=Release \
  -DBUILD_NUMBER=$MUMBLE_BUILD_NUMBER \
  -Dclient=OFF \
  -Dserver=ON \
  -Dice=OFF \
  -Dlto=ON \
  -Dtests=ON \
  -Dwarnings-as-errors=OFF \
  -Dzeroconf=OFF \
  -DCMAKE_UNITY_BUILD=ON \
  -DBUILD_SHARED_LIBS=True \
  -Doverlay-xcompile=OFF \
  -Dspeechd=OFF \
  -Dice=OFF \
  -Drnnoise=ON \
  -Dbundled-celt=OFF \
  -Dbundle-qt-translations=OFF \
  -Dbundled-speex=OFF \
  -Dbundled-opus=OFF \
  -Dbundled-rnnoise=OFF \
  -Dupdate=OFF \
  $DOCKER_CMAKE_ARGS

RUN cmake --build build


FROM base
RUN addgroup -g 1000 mumble; \
  adduser -u 1000 -G mumble -D -h /tmp/mumble -s /sbin/nologin mumble; \
  chmod 700 /tmp/mumble

EXPOSE 64738 64738/udp

COPY --from=builder /tmp/mumble/build/mumble-server /usr/bin/mumble-server

USER mumble
RUN umask 077
CMD ["mumble-server", "-fg", "-ini", "/config/mumble-server.ini", "-v"]
