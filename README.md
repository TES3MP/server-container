# TES3MP-docker
Docker image for the TES3MP server

## Running in interactive mode

```
docker run -it -v "./data:/server/data" -p "25565:25565/udp" grimkriegor/tes3mp-server
```

## Using with Docker Compose

```yml
version: '3'
services:
  server:
    image: "grimkriegor/tes3mp-server"
    volumes:
      - "./data:/server/data"
    ports:
      - "25565:25565/udp"
```
