FROM alpine:latest as builder

ENV TES3MP_VERSION 0.6.3

ARG BUILD_THREADS="4"

RUN apk add --no-cache \
    libgcc \
    libstdc++ \
    boost-system \
    boost-filesystem \
    boost-dev \
    luajit-dev \
    make \
    cmake \
    build-base \
    openssl-dev \
    ncurses \
    mesa-dev \
    bash \
    git \
    wget

RUN git clone --depth 1 -b "${TES3MP_VERSION}" https://github.com/TES3MP/openmw-tes3mp.git /tmp/TES3MP \
    && git clone --depth 1 -b "${TES3MP_VERSION}" https://github.com/TES3MP/CoreScripts.git /tmp/CoreScripts \
    && git clone --depth 1 https://github.com/Koncord/CallFF.git /tmp/CallFF \
    && git clone --depth 1 https://github.com/TES3MP/CrabNet.git /tmp/CrabNet \
    && git clone --depth 1 https://github.com/OpenMW/osg.git /tmp/osg

RUN cd /tmp/CallFF \
    && mkdir build \
    && cd build \
    && cmake .. \
    && make -j ${BUILD_THREADS}

RUN cd /tmp/CrabNet \
    && git reset --hard origin/master \
    && mkdir build \
    && cd build \
    && cmake -DCMAKE_BUILD_TYPE=Release ..\
    && cmake --build . --target RakNetLibStatic --config Release -- -j ${BUILD_THREADS}

RUN cd /tmp/osg \
    && cmake .

RUN cd /tmp/TES3MP \
    && mkdir build \
    && cd build \
    && RAKNET_ROOT=/tmp/CrabNet/build \
        cmake .. \
        -DCMAKE_BUILD_TYPE=Release \
        -DBUILD_OPENMW_MP=ON \
        -DBUILD_OPENMW=OFF \
        -DBUILD_OPENCS=OFF \
        -DBUILD_BROWSER=OFF \
        -DBUILD_BSATOOL=OFF \
        -DBUILD_ESMTOOL=OFF \
        -DBUILD_ESSIMPORTER=OFF \
        -DBUILD_LAUNCHER=OFF \
        -DBUILD_MWINIIMPORTER=OFF \
        -DBUILD_MYGUI_PLUGIN=OFF \
        -DBUILD_OPENMW=OFF \
        -DBUILD_WIZARD=OFF \
        -DCallFF_INCLUDES=/tmp/CallFF/include \
        -DCallFF_LIBRARY=/tmp/CallFF/build/src/libcallff.a \
        -DOPENSCENEGRAPH_INCLUDE_DIRS=/tmp/osg/include \
    && make -j ${BUILD_THREADS}

RUN mv /tmp/TES3MP/build /server \
    && mv /tmp/CoreScripts /server/Corescripts \
    && sed -i "s|home = .*|home = /server/data|g" /server/tes3mp-server-default.cfg \
    && mkdir /server/data

FROM alpine:latest

LABEL maintainer="Grim Kriegor <grimkriegor@krutt.org>"
LABEL description="Docker image for the TES3MP server"

RUN apk add --no-cache \
        libgcc \
        libstdc++ \
        boost-system \
        boost-filesystem \
        luajit \
        bash

COPY --from=builder /server /
ADD bootstrap.sh /bootstrap.sh

EXPOSE 25565/udp
VOLUME /server

WORKDIR /server
ENTRYPOINT [ "/bin/bash", "/bootstrap.sh", "--",  "/bin/bash", "tes3mp-server" ]
