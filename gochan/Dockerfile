# SPDX-License-Identifier: WTFPL
ARG BASE_IMAGE=cgr.dev/chainguard/wolfi-base:latest
ARG GOCHAN_VERSION=4.3.0

FROM $BASE_IMAGE as base
RUN apk -v --no-cache update && \
  apk -v --no-cache upgrade -la && \
  apk -v --no-cache add \
  ca-certificates \
  ca-certificates-bundle \
  ca-certificates-bundle-ecs \
  ffmpeg \
  openssl \
  exiftool \
  nodejs

RUN update-ca-certificates


FROM base as builder
ARG GOCHAN_VERSION

RUN apk -v --no-cache add \
  python3 \
  gcc \
  glibc-dev \
  npm


RUN addgroup -g 1000 gochan && \
  adduser -u 1000 -G gochan -D -h /tmp/build -s /sbin/nologin gochan && \
  mkdir -p /tmp/gochan-$GOCHAN_VERSION /tmp/build

RUN update-ca-certificates
RUN update-ca-certificates
RUN update-ca-certificates
RUN update-ca-certificates
RUN update-ca-certificates

ADD --checksum=sha256:33c1d4d96e8b5cd09262248c957f1facfc5b03b46c10548ab2ce37c26cd321e2 \
  https://github.com/gochan-org/gochan/archive/refs/tags/v$GOCHAN_VERSION.tar.gz /tmp/build

RUN chown -R gochan:gochan /tmp/build/ /tmp/gochan-$GOCHAN_VERSION && \
  chmod 700 /tmp/build/ /tmp/gochan-$GOCHAN_VERSION

USER gochan

RUN ls -la /tmp/build && tar xf /tmp/build/v$GOCHAN_VERSION.tar.gz -C /tmp && \
  rm /tmp/build/v$GOCHAN_VERSION.tar.gz && ls -la /tmp

WORKDIR /tmp/gochan-$GOCHAN_VERSION

ENV NODE_ENV=prod
RUN npm --prefix frontend/ ci && \
	npm --prefix frontend/ run build-ts && \
	go mod tidy && \
	./build.py && \
	./build.py install
