# Mumble Rootless Container
A minimal musl libc mumble imge compiled with -O3.

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
    image: localhost/mumble:latest
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
