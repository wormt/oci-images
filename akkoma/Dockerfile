# SPDX-License-Identifier: WTFPL
FROM hexpm/elixir:1.19.6-erlang-28.5.0.8-alpine-3.24.3 as base
RUN apk -v --no-cache update && \
	apk -v --no-cache upgrade -la && \
	apk -v --no-cache add \
		ca-certificates \
		exiftool \
		ffmpeg \
		imagemagick \
		postgresql17-client \
		file \
		libmagic \
		libarchive \
		libatomic

RUN update-ca-certificates

# hey girl are you a construction worker because you are from base building
FROM base as building
RUN apk -v --no-cache add \
	git \
	tar \
	musl-dev \
	build-base \
	cmake \
	file-dev

ADD --checksum=sha256:7179ac872c621df878cbcea85cb806343b31c098f2a5f4b81dfd87a808dd4de9 \
	https://codeberg.org/ratmaxxing/akkoma/archive/0439c39c132c6707c55a9153cdba16345a4f8b28.tar.gz /tmp/akkoma.tar.gz
RUN tar xf /tmp/akkoma.tar.gz -C /tmp
WORKDIR /tmp/akkoma

ARG MIX_ENV=prod
RUN mix local.rebar --force && \
	mix local.hex --force && \
	mix deps.get && \
	mix release --overwrite --path otp

FROM base
RUN addgroup -g 1000 akkoma && \
	adduser -h /opt/akkoma -s /sbin/nologin -G akkoma -D -u 1000 akkoma && \
	chmod 700 /opt/akkoma
COPY --chmod=700 --chown=akkoma:akkoma --from=building \
	/tmp/akkoma/otp /opt/akkoma

USER akkoma
WORKDIR /opt/akkoma
CMD ["./bin/pleroma","start"]
