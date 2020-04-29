FROM ubuntu:20.04

ARG userid
ARG groupid
ARG username
ENV TERM=screen-256color

# set timezone before install tzdata and switch apt to TW mirror.
RUN ln -fs /usr/share/zoneinfo/Asia/Taipei /etc/localtime \
  && sed --in-place --regexp-extended "s/(\/\/)(archive\.ubuntu)/\1tw.\2/" /etc/apt/sources.list \
  && apt-get -qq update && DEBIAN_FRONTEND=noninteractive apt-get -qqy install tzdata

# installing required packages.
RUN DEBIAN_FRONTEND=noninteractive apt-get -qqy install git-core build-essential \
  bc gnupg flex bison gperf zip curl zlib1g-dev gcc-multilib g++-multilib \
  libc6-dev-i386 lib32ncurses5-dev x11proto-core-dev libx11-dev lib32z-dev \
  ccache libgl1-mesa-dev libxml2-utils xsltproc unzip \
  && apt-get clean && rm -rf /var/lib/apt/lists/*

# download GNU toolchain for the Cortex-A family
RUN mkdir -p /opt/linaro/aarch64 && cd /opt/linaro/aarch64 \
  && curl -LO https://releases.linaro.org/components/toolchain/binaries/7.5-2019.12/aarch64-linux-gnu/gcc-linaro-7.5.0-2019.12-x86_64_aarch64-linux-gnu.tar.xz \
  -LO https://releases.linaro.org/components/toolchain/binaries/7.5-2019.12/aarch64-linux-gnu/gcc-linaro-7.5.0-2019.12-x86_64_aarch64-linux-gnu.tar.xz.asc \
  && md5sum --check gcc-linaro-7.5.0-2019.12-x86_64_aarch64-linux-gnu.tar.xz.asc \
  && tar xf gcc-linaro-7.5.0-2019.12-x86_64_aarch64-linux-gnu.tar.xz --strip-components=1 \
  && rm gcc-linaro-7.5.0-2019.12-x86_64_aarch64-linux-gnu.tar.xz \
  gcc-linaro-7.5.0-2019.12-x86_64_aarch64-linux-gnu.tar.xz.asc

ENV PATH /opt/linaro/aarch64/bin:$PATH

RUN groupadd -g $groupid $username \
  && useradd -m -u $userid -g $groupid $username \
  && echo "export USER="$username >>/home/$username/.gitconfig

COPY gitconfig /home/$username/.gitconfig
RUN chown $userid:$groupid /home/$username/.gitconfig

ENV HOME=/home/$username
ENV USER=$username
ENTRYPOINT /bin/bash -i
