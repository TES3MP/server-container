# Base the container in Debian Jessie
FROM debian:stretch

LABEL maintainer="Grim Kriegor <grimkriegor@krutt.org>"
LABEL description="Docker image for the TES3MP server"

# Package location
ENV PACKAGE "https://grimkriegor.zalkeen.net/public/tes3mp%2dserver%2dGNU%2bLinux%2dx86%5f64%2drelease%2d0.6.2.1%2df1d0e95a27%2db223d84d82.tar.gz"

# Download and extract
ADD $PACKAGE /package.tar.gz
RUN mkdir /server && \
    tar xvf package.tar.gz --directory / && \
    mv /TES3MP-server /server

# Expose server ports
EXPOSE 25565/udp

# Expose volumes
VOLUME /server

# Working directory
WORKDIR /server

# Entrypoint
ENTRYPOINT [ "/bin/bash", "tes3mp-server.sh" ]
