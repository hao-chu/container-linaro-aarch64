FROM ubuntu:19.04

ARG userid
ARG groupid
ARG username
ENV TERM=screen-256color

RUN sed --in-place --regexp-extended "s/(\/\/)(archive\.ubuntu)/\1tw.\2/" /etc/apt/sources.list \
  && apt-get -qq update && apt-get -qqy install git-core build-essential bc gnupg flex bison gperf \
  zip curl zlib1g-dev gcc-multilib g++-multilib libc6-dev-i386 lib32ncurses5-dev x11proto-core-dev \
  libx11-dev lib32z-dev ccache libgl1-mesa-dev libxml2-utils xsltproc unzip \
  && apt-get clean && rm -rf /var/lib/apt/lists/*

RUN mkdir -p /opt/linaro/aarch64 && cd /opt/linaro/aarch64 \
  && curl -Lo linaro-cross.tar.xz \
  https://releases.linaro.org/components/toolchain/binaries/7.5-2019.12/aarch64-linux-gnu/gcc-linaro-7.5.0-2019.12-x86_64_aarch64-linux-gnu.tar.xz \
  && tar xf linaro-cross.tar.xz --strip-components=1 \
  && rm linaro-cross.tar.xz

ENV PATH /opt/linaro/aarch64/bin:$PATH

RUN groupadd -g $groupid $username \
  && useradd -m -u $userid -g $groupid $username \
  && echo "export USER="$username >>/home/$username/.gitconfig

COPY gitconfig /home/$username/.gitconfig
RUN chown $userid:$groupid /home/$username/.gitconfig

ENV HOME=/home/$username
ENV USER=$username
ENTRYPOINT /bin/bash -i
