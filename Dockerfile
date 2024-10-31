ARG DOCKER_BASE_IMAGE
FROM $DOCKER_BASE_IMAGE

ARG DOCKER_BASE_IMAGE
ENV DOCKER_BASE_IMAGE="${DOCKER_BASE_IMAGE}"

SHELL ["bash", "-euxo", "pipefail", "-c"]


RUN set -euxo pipefail >/dev/null \
&& if [[ "$DOCKER_BASE_IMAGE" != centos* ]] && [[ "$DOCKER_BASE_IMAGE" != *manylinux2014* ]]; then exit 0; fi \
&& sed -i "s/enabled=1/enabled=0/g" "/etc/yum/pluginconf.d/fastestmirror.conf" \
&& sed -i "s/enabled=1/enabled=0/g" "/etc/yum/pluginconf.d/ovl.conf" \
&& yum clean all \
&& yum install -y epel-release \
&& yum install -y \
  bash \
  ca-certificates \
  curl \
  git \
  make \
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
  clang \
  curl \
  git \
  gnupg \
  libedit-dev \
  libncurses5-dev \
  make \
  sudo \
  tar \
  xz-utils \
  zlib1g-dev \
>/dev/null \
&& rm -rf /var/lib/apt/lists/* \
&& apt-get clean autoclean >/dev/null \
&& apt-get autoremove --yes >/dev/null


ENV MY_PYTHON_ROOT="/opt/python/cp38-cp38"
ENV PATH="${MY_PYTHON_ROOT}/bin:${PATH}"
ENV C_INCLUDE_PATH="${MY_PYTHON_ROOT}/include:${C_INCLUDE_PATH}"
ENV CPLUS_INCLUDE_PATH="${MY_PYTHON_ROOT}/include:${CPLUS_INCLUDE_PATH}"
ENV LD_LIBRARY_PATH="${MY_PYTHON_ROOT}/lib:${LD_LIBRARY_PATH}"
ENV PKG_CONFIG_PATH="${MY_PYTHON_ROOT}/lib/pkgconfig:${PKG_CONFIG_PATH}"
RUN set -euxo pipefail >/dev/null \
&& pip3 install --upgrade \
  pip \
  pyyaml \
  swig \
&& pip cache purge >/dev/null \
&& rm -rf "/opt/_internal/pipx"


#ENV MY_SYSROOT_DIR="/usr/x86_64-unknown-linux-gnu"
#ENV CC="/usr/bin/x86_64-unknown-linux-gnu-gcc"
#ENV CXX="/usr/bin/x86_64-unknown-linux-gnu-g++"
#ENV FC="/usr/bin/x86_64-unknown-linux-gnu-gfortran"
#ENV AR="/usr/bin/x86_64-unknown-linux-gnu-ar"
#ENV AS="/usr/bin/x86_64-unknown-linux-gnu-as"
#ENV LD="/usr/bin/x86_64-unknown-linux-gnu-ld"
#ENV NM="/usr/bin/x86_64-unknown-linux-gnu-nm"
#ENV OBJCOPY="/usr/bin/x86_64-unknown-linux-gnu-objcopy"
#ENV OBJDUMP="/usr/bin/x86_64-unknown-linux-gnu-objdump"
#ENV RANLIB="/usr/bin/x86_64-unknown-linux-gnu-ranlib"
#ENV STRIP="/usr/bin/x86_64-unknown-linux-gnu-strip"
#ENV PATH="$MY_SYSROOT_DIR/bin:${PATH}"
#ENV C_INCLUDE_PATH="${MY_SYSROOT_DIR}/include:${C_INCLUDE_PATH}"
#ENV CPLUS_INCLUDE_PATH="${MY_SYSROOT_DIR}/include:${CPLUS_INCLUDE_PATH}"
#ENV LIBRARY_PATH="${MY_SYSROOT_DIR}/lib64:${LIBRARY_PATH}"
#ENV PKG_CONFIG_PATH="${MY_SYSROOT_DIR}/lib64/pkgconfig:${MY_SYSROOT_DIR}/share/pkgconfig"
#RUN set -euxo pipefail >/dev/null \
#&& curl -fsSL "https://github.com/binarylandia/build_crosstool-ng/releases/download/2024-10-30_06-02-56/gcc-14.2.0-x86_64-unknown-linux-gnu-2024-10-30_06-02-56.tar.xz" | tar -C "/usr" -xJ \
#&& which x86_64-unknown-linux-gnu-gcc \
#&& /usr/bin/x86_64-unknown-linux-gnu-gcc -v

ENV MY_SYSROOT_DIR="/usr/x86_64-unknown-linux-musl"
ENV CC="/usr/bin/x86_64-unknown-linux-musl-gcc"
ENV CXX="/usr/bin/x86_64-unknown-linux-musl-g++"
ENV FC="/usr/bin/x86_64-unknown-linux-musl-gfortran"
ENV AR="/usr/bin/x86_64-unknown-linux-musl-ar"
ENV AS="/usr/bin/x86_64-unknown-linux-musl-as"
ENV LD="/usr/bin/x86_64-unknown-linux-musl-ld"
ENV NM="/usr/bin/x86_64-unknown-linux-musl-nm"
ENV OBJCOPY="/usr/bin/x86_64-unknown-linux-musl-objcopy"
ENV OBJDUMP="/usr/bin/x86_64-unknown-linux-musl-objdump"
ENV RANLIB="/usr/bin/x86_64-unknown-linux-musl-ranlib"
ENV STRIP="/usr/bin/x86_64-unknown-linux-musl-strip"
ENV PATH="$MY_SYSROOT_DIR/bin:${PATH}"
ENV C_INCLUDE_PATH="${MY_SYSROOT_DIR}/include:${C_INCLUDE_PATH}"
ENV CPLUS_INCLUDE_PATH="${MY_SYSROOT_DIR}/include:${CPLUS_INCLUDE_PATH}"
ENV LIBRARY_PATH="${MY_SYSROOT_DIR}/lib64:${LIBRARY_PATH}"
ENV PKG_CONFIG_PATH="${MY_SYSROOT_DIR}/lib64/pkgconfig:${MY_SYSROOT_DIR}/share/pkgconfig"
RUN set -euxo pipefail >/dev/null \
&& curl -fsSL "https://github.com/binarylandia/build_crosstool-ng/releases/download/2024-10-30_06-02-56/gcc-10.5.0-x86_64-unknown-linux-musl-2024-10-30_06-02-56.tar.xz" | tar -C "/usr" -xJ \
&& which x86_64-unknown-linux-musl-gcc \
&& /usr/bin/x86_64-unknown-linux-musl-gcc -v

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
&& curl -fsSL "https://github.com/binarylandia/build_zlib/releases/download/zlib-1.3.1-static-20241028131008/zlib-1.3.1-static-20241028131008.tar.xz" | tar -C "/usr" -xJ \
&& ls /usr/include/zlib.h \
&& ls /usr/lib/libz.a


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
