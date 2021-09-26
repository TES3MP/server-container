FROM alpine:3.10 as builder

ENV TES3MP_VERSION 0.7.0
ENV TES3MP_VERSION_STRING 0.44.0\\n292536439eeda58becdb7e441fe2e61ebb74529e

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
    && git clone https://github.com/TES3MP/CrabNet.git /tmp/CrabNet \
    && git clone --depth 1 https://github.com/OpenMW/osg.git /tmp/osg

RUN cd /tmp/CrabNet \
    && git reset --hard origin/master \
    && git checkout 4eeeaad2f6c11aeb82070df35169694b4fb7b04b \
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
        -DOPENSCENEGRAPH_INCLUDE_DIRS=/tmp/osg/include \
    && make -j ${BUILD_THREADS}

RUN mv /tmp/TES3MP/build /server \
    && mv /tmp/CoreScripts /server/CoreScripts \
    && sed -i "s|home = .*|home = /server/data|g" /server/tes3mp-server-default.cfg \
    && echo -e ${TES3MP_VERSION_STRING} > /server/resources/version \
    && cp /tmp/TES3MP/tes3mp-credits.md /server/ \
    && mkdir /server/data

FROM alpine:3.10

LABEL maintainer="Grim Kriegor <grimkriegor@krutt.org>"
LABEL description="Docker image for the TES3MP server"

RUN apk add --no-cache \
        libgcc \
        libstdc++ \
        boost-system \
        boost-filesystem \
        boost-program_options \
        luajit \
        bash

COPY --from=builder /server /server
ADD entrypoint.sh /entrypoint.sh

EXPOSE 25565/udp
VOLUME /data

WORKDIR /server
ENTRYPOINT [ "/bin/bash", "/entrypoint.sh" ]
