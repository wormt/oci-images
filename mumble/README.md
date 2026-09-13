# Mumble Rootless Container
A minimal alpine mumble image compiled with -O3.

This container is meant for a rootless podman setup. It does not use entrypoint
& drops to user 1000 at the end of the build process. It is expected you have
userns_mode="keep-id:uid=1000,gid=1000" such as in this repo's example
docker-compose.yml file.

## docker-compose.yml
```
---
name: 'mumble'
version: '3.9'

x-podman:
  in-pod: false

services:
  murmur:
    image: docker.io/wormt/mumble:latest
    build:
      dockerfile: ./Dockerfile
    container_name: mumble
    restart: on-failure:69
    userns_mode: "keep-id:uid=1000,gid=1000"
    ports:
      - "64738:64738/udp"
      - "64738:64738/tcp"
    volumes:
      - "mumble-db:/data:U"
      - type: bind
        source: ./config
        target: /config
        bind:
          selinux: Z
          create_host_path: true
      - type: bind
        source: ./ssl
        target: /ssl
        read_only: true
        bind:
          selinux: Z
          create_host_path: true

volumes:
  mumble-db: {name: "mumble-db"}
```

## quadlet
```
[Unit]
Description=Mumble

[Container]
ContainerName=mumble

Image=docker.io/wormt/mumble:latest
AutoUpdate=registry

UserNS=keep-id:uid=1000,gid=1000

PublishPort=64738:64738/udp
PublishPort=64738:64738/tcp

Volume=mumble-db:/data:U
Volume=/opt/mumble/compose/config:/config:Z
Volume=/opt/mumble/compose/ssl:/ssl:ro,Z

[Service]
Restart=always

[Install]
WantedBy=default.target
```
