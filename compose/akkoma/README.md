# Akkoma OCI Image
this image is meant to be ran rootless with akkoma uid mapped to 1000. the easiest way to do that is with podman's userns_mode keep-id.

- [https://codeberg.org/wormt/compose/src/branch/akkoma](repo)
- [https://hub.docker.com/r/wormt/akkoma](registry)

## docker-compose.yml
Requires an external secret pg_pass & environment vars POSTGRES_DB & POSTGRES_USER set, as well as a volume for uploads.
```
---
name: 'akkoma'
version: '3.9'

x-podman:
  in_pod: false

services:
  psql:
    image: postgres:17.6-alpine3.22
    container_name: psql
    shm_size: 4gb
    restart: on-failure:10
    userns_mode: "keep-id:uid=70,gid=70"
    environment: {
      POSTGRES_PASSWORD: /run/secrets/pg_pass,
    }
    secrets:
      - pg_pass
    volumes:
      - type: bind
        source: ./pgconf
        target: /etc/postgresql
        bind:
          selinux: z
        create_host_path: true
      - type: bind
        source: ./pgdata
        target: /var/lib/postgresql/data
        bind:
          selinux: Z
        create_host_path: true
    healthcheck:
      test: pg_isready -U $POSTGRES_USER -d $POSTGRES_DB
      interval: 8s
      timeout: 3s
      retries: 5
    networks:
      akkoma-psql:

  akkoma:
    depends_on:
      - psql
    # image: docker.io/wormt/akkoma:latest
    image: localhost/akkoma:latest
    build:
      dockerfile: ./Dockerfile
    container_name: akkoma
    # command: sleep 60000
    restart: on-failure:10
    # restart: always
    userns_mode: "keep-id:uid=1000,gid=1000"
    ports:
      - "4000:4000/tcp"
    volumes:
      - type: bind
        source: ./config
        target: /etc/akkoma
        bind:
          selinux: Z
          create_host_path: true
      - type: bind
        source: ./static
        target: /var/lib/akkoma/static
        bind:
          selinux: Z
          create_host_path: true
      - type: volume
        source: akkoma-uploads
        target: /var/lib/akkoma/uploads
        x-driver_opts: U
    networks:
      akkoma-psql:

volumes:
  akkoma-pgdata: {name: "akkoma-pgdata"}
  akkoma-pgconf: {name: "akkoma-pgconf"}
  akkoma-uploads: {name: "akkoma-uploads"}

networks:
  akkoma-psql: {name: "akkoma-psql"}

secrets:
  pg_pass: {external: true}
```

## quadlet
### psql.container
Requires an external secret pg_pass as well as a volume for uploads.
```
[Unit]
Requires=psql.service
After=psql.service

[Container]
ContainerName=akkoma
Image=docker.io/wormt/akkoma:latest
UserNS=keep-id:uid=1000,gid=1000
PublishPort=4000:4000/tcp
Network=akkoma-psql
Volume=/opt/akkoma/compose/config:/etc/akkoma:Z
Volume=/opt/akkoma/compose/static:/var/lib/akkoma/static:Z
Volume=akkoma-uploads:/var/lib/akkoma/uploads:U

[Install]
WantedBy=default.target
```

### akkoma.container
```
[Unit]
Description=Akkoma Server
Requires=psql.service
After=psql.service

[Container]
ContainerName=akkoma
Image=localhost/akkoma:latest
#Image=docker.io/wormt/akkoma:latest
AutoUpdate=registry
UserNS=keep-id:uid=1000,gid=1000
PublishPort=4000:4000/tcp
Network=akkoma-psql
Volume=/opt/akkoma/compose/config:/etc/akkoma:Z
Volume=/opt/akkoma/compose/static:/var/lib/akkoma/static:Z
Volume=akkoma-uploads:/var/lib/akkoma/uploads:U

[Install]
WantedBy=default.target
```
