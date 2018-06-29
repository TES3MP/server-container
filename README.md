# TES3MP-docker
Docker image for the TES3MP server

## Docker Hub

https://hub.docker.com/r/grimkriegor/tes3mp-server/

## Getting the image

### Pulling from Docker Hub

```
docker pull grimkriegor/tes3mp-server
```

### Building

```bash
git clone https://github.com/GrimKriegor/TES3MP-docker.git
cd TES3MP-docker
git checkout <TES3MP version> # optional
docker build -t grimkriegor/tes3mp-server:<TES3MP version> .
```

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
