# syntax=docker/dockerfile:1
# check=experimental=all
ARG DOCKER_BASE_IMAGE
FROM ${DOCKER_BASE_IMAGE}

SHELL ["bash", "-euxo", "pipefail", "-c"]

ENV HOST_TUPLE="x86_64-unknown-linux-gnu"

# The GCC, glibc, and libstdc++ of Debian serve only the checks of the finished
# installation, which compile and run programs the way a user of a current
# distribution does. 64-bit Wine runs the x86_64 Windows test programs of
# scripts/test-mingw.
RUN set -euxo pipefail >/dev/null \
&& export DEBIAN_FRONTEND=noninteractive \
&& apt-get update -qq \
&& apt-get install --no-install-recommends --yes -qq \
  bash \
  binutils \
  bzip2 \
  ca-certificates \
  ccache \
  cmake \
  curl \
  file \
  g++ \
  gcc \
  git \
  gzip \
  jq \
  libc6-dev \
  make \
  ninja-build \
  parallel \
  patch \
  pigz \
  python3 \
  sudo \
  tar \
  unzip \
  wine \
  wine64 \
  xz-utils \
  zstd \
>/dev/null \
&& apt-get clean autoclean >/dev/null \
&& apt-get autoremove --yes >/dev/null \
&& rm -rf /var/lib/apt/lists/* /var/cache/apt/archives/*

COPY --link "dev/docker/files/distrust-compromised-roots" "/"
RUN /distrust-compromised-roots

COPY --link "dev/docker/files/fetch" "dev/docker/files/checksums" "/"

# GCC 16 on glibc 2.17, the compiler of the first stage and the sysroot of all
# stages (see install-host-gcc).
ENV HOST_GCC_DIR="/opt/host-gcc"
COPY --link "dev/docker/files/install-host-gcc" "/"
RUN /install-host-gcc "${HOST_GCC_DIR}"
ENV HOST_GCC_RECORD="${HOST_GCC_DIR}/toolchain.json"

# The libraries that the LLVM tools link statically (see install-host-libs).
ENV HOST_LIBS_DIR="/opt/host-libs"
COPY --link "dev/docker/files/install-host-libs" "/"
RUN /install-host-libs "${HOST_GCC_DIR}" "${HOST_LIBS_DIR}"

ARG USER=user
ARG GROUP=user
ARG UID
ARG GID

ENV USER=$USER
ENV GROUP=$GROUP
ENV UID=$UID
ENV GID=$GID
ENV TERM="xterm-256color"
ENV HOME="/home/${USER}"

COPY --link "dev/docker/files/create-user" "/"
RUN /create-user


USER ${USER}
