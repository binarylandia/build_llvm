ARG DOCKER_BASE_IMAGE
FROM $DOCKER_BASE_IMAGE

ARG DOCKER_BASE_IMAGE
ENV DOCKER_BASE_IMAGE="${DOCKER_BASE_IMAGE}"

SHELL ["bash", "-euxo", "pipefail", "-c"]

RUN set -euxo pipefail >/dev/null \
&& if [[ "$DOCKER_BASE_IMAGE" != centos* ]] && [[ "$DOCKER_BASE_IMAGE" != *manylinux2014* ]]; then exit 0; fi \
&& sed -i "s/enabled=1/enabled=0/g" "/etc/yum/pluginconf.d/fastestmirror.conf" \
&& sed -i "s/enabled=1/enabled=0/g" "/etc/yum/pluginconf.d/ovl.conf" \
&& yum clean all >/dev/null \
&& yum install -y epel-release >/dev/null \
&& yum remove -y \
  clang* \
  devtoolset* \
  gcc* \
  llvm-toolset* \
>/dev/null \
&& yum install -y \
  bash \
  ca-certificates \
  curl \
  devtoolset-11 \
  git \
  make \
  parallel \
  sudo \
  tar \
  xz \
>/dev/null \
&& yum clean all >/dev/null \
&& rm -rf /var/cache/yum


RUN set -euxo pipefail >/dev/null \
&& if [[ "$DOCKER_BASE_IMAGE" != debian* ]] && [[ "$DOCKER_BASE_IMAGE" != ubuntu* ]]; then exit 0; fi \
&& export DEBIAN_FRONTEND=noninteractive \
&& apt-get update -qq --yes \
&& apt-get install -qq --no-install-recommends --yes \
  bash \
  ca-certificates \
  curl \
  git \
  gnupg \
  libedit-dev \
  libncurses5-dev \
  make \
  parallel \
  sudo \
  tar \
  xz-utils \
>/dev/null \
&& rm -rf /var/lib/apt/lists/* \
&& apt-get clean autoclean >/dev/null \
&& apt-get autoremove --yes >/dev/null

RUN set -euxo pipefail >/dev/null \
&& export PATH="/opt/python/cp38-cp38/bin:${PATH}" \
&& pip3 install --upgrade \
  pip \
  pyyaml \
  swig \
&& pip cache purge >/dev/null \
&& rm -rf "/opt/_internal/pipx"

ENV CCACHE_DIR="/cache/ccache"
ENV CCACHE_NOCOMPRESS="1"
ENV CCACHE_MAXSIZE="50G"
RUN set -euxo pipefail >/dev/null \
&& curl -fsSL "https://github.com/ccache/ccache/releases/download/v4.10.2/ccache-4.10.2-linux-x86_64.tar.xz" | tar --strip-components=1 -C "/usr/bin" -xJ "ccache-4.10.2-linux-x86_64/ccache" \
&& which ccache \
&& ccache --version

RUN set -euxo pipefail >/dev/null \
&& curl -fsSL "https://github.com/Kitware/CMake/releases/download/v3.30.5/cmake-3.30.5-linux-x86_64.tar.gz" | tar --strip-components=1 -C "/usr" -xz \
&& which cmake \
&& cmake --version

RUN set -euxo pipefail >/dev/null \
&& curl -fsSL "https://github.com/binarylandia/build_zlib/releases/download/zlib-1.3.1-static-20241031112952/zlib-1.3.1-static-20241031112952.tar.xz" | tar -C "/usr" -xJ \
&& ls /usr/include/zlib.h \
&& ls /usr/lib/libz.a

RUN set -euxo pipefail >/dev/null \
&& curl -fsSL "https://github.com/binarylandia/build_libxml2/releases/download/libxml2-2.12.9-static-20241031113236/libxml2-2.12.9-static-20241031113236.tar.xz" | tar -C "/usr" -xJ \
&& ls /usr/include/libxml/xmlwriter.h \
&& ls /usr/lib/libxml2.a

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

COPY docker/files /

RUN set -euxo pipefail >/dev/null \
&& /create-user \
&& sed -i /etc/sudoers -re 's/^%sudo.*/%sudo ALL=(ALL:ALL) NOPASSWD: ALL/g' \
&& sed -i /etc/sudoers -re 's/^root.*/root ALL=(ALL:ALL) NOPASSWD: ALL/g' \
&& sed -i /etc/sudoers -re 's/^#includedir.*/## **Removed the include directive** ##"/g' \
&& echo "%sudo ALL=(ALL) NOPASSWD:ALL" >> /etc/sudoers \
&& echo "${USER} ALL=(ALL) NOPASSWD:ALL" >> /etc/sudoers \
&& touch ${HOME}/.hushlogin \
&& chown -R ${UID}:${GID} "${HOME}"

USER ${USER}

ENTRYPOINT ["scl", "enable", "devtoolset-11", "--"]
