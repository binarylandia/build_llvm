# syntax=docker/dockerfile:1
# check=experimental=all
FROM quay.io/pypa/manylinux2014_x86_64

SHELL ["bash", "-euxo", "pipefail", "-c"]

ENV HOST_TUPLE_DEBIAN="x86_64-linux-gnu"
ENV HOST_TUPLE="x86_64-unknown-linux-gnu"
ENV HOST_GCC_TRIPLET="x86_64-unknown-linux-gnu"

RUN set -euxo pipefail >/dev/null \
&& sed -i "s/enabled=1/enabled=0/g" "/etc/yum/pluginconf.d/fastestmirror.conf" \
&& sed -i "s/enabled=1/enabled=0/g" "/etc/yum/pluginconf.d/ovl.conf" \
&& yum clean all >/dev/null \
&& yum install -y epel-release >/dev/null \
&& yum remove -y \
  ccache* \
  clang* \
  cmake* \
  devtoolset* \
  gcc* \
  llvm-toolset* \
>/dev/null \
&& yum install -y \
  bash \
  ca-certificates \
  curl \
  git \
  gzip \
  parallel \
  pigz \
  sudo \
  tar \
  xz \
  zstd \
>/dev/null \
&& yum clean all >/dev/null \
&& rm -rf /var/cache/yum \

ARG PREFIX_HOST="/usr"
ARG HOST_GCC_DIR="/usr"

ENV PREFIX_HOST="${PREFIX_HOST}"
ENV HOST_GCC_DIR="${HOST_GCC_DIR}"

COPY --link "dev/docker/files/install-gcc" "/"
RUN /install-gcc "${HOST_GCC_DIR}"

COPY --link "dev/docker/files/install-cmake" "/"
RUN /install-cmake

COPY --link "dev/docker/files/install-ccache" "/"
RUN /install-ccache

COPY --link "dev/docker/files/install-libbzip2" "/"
RUN /install-libbzip2 "${HOST_TUPLE}" "${PREFIX_HOST}"

COPY --link "dev/docker/files/install-liblzma" "/"
RUN /install-liblzma "${HOST_TUPLE}" "${PREFIX_HOST}"

COPY --link "dev/docker/files/install-libz" "/"
RUN /install-libz "${HOST_TUPLE}" "${PREFIX_HOST}"

COPY --link "dev/docker/files/install-libzstd" "/"
RUN /install-libzstd "${HOST_TUPLE}" "${PREFIX_HOST}"

COPY --link "dev/docker/files/install-libffi" "/"
RUN /install-libffi "${HOST_TUPLE}" "${PREFIX_HOST}"

COPY --link "dev/docker/files/install-libxml" "/"
RUN /install-libxml "${HOST_TUPLE}" "${PREFIX_HOST}"

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
