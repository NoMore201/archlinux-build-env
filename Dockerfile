FROM archlinux:latest

ENV BUILD_DIR /home/builder
ENV OUTPUT_DIR $BUILD_DIR/out

# enable multilib repository
COPY pacman.conf /etc/pacman.conf

# install basic dependencies
RUN pacman -Syu --noconfirm \
    git \
    asp \
    lib32-gcc-libs \
    base-devel && \
    rm -rf /var/cache/pacman/pkg/*

RUN useradd -m -s /bin/bash builder

USER builder
WORKDIR $BUILD_DIR
COPY run.sh .
RUN mkdir -p $OUTPUT_DIR

VOLUME $OUTPUT_DIR

USER root
ENTRYPOINT ["bash", "./run.sh"]
