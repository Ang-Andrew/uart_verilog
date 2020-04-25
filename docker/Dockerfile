# Pull Ubuntu 18.04
FROM ubuntu:18.04

ENV DEBIAN_FRONTEND=noninteractive

# Installing dependencies
RUN \
  apt-get update && \
  apt-get install --no-install-recommends -y \
                  autoconf \
                  bc \
                  bison \
                  build-essential \
                  ca-certificates \
                  cmake \
                  flex \
                  gdb \
                  gcc-6 \
                  gcc-5 \
                  gcc-4.8 \
                  git \
                  gtkwave \
                  g++-6 \
                  g++-5 \
                  g++-4.8 \
                  libfl2 \
                  libfl-dev \
                  numactl \
                  perl \
                  python3 \
                  wget \
                  zlibc \
                  zlib1g \
                  zlib1g-dev \
                  verilator \
  && apt-get clean \
  && rm -rf /var/lib/apt/lists/*

# Getting Verilator source
# RUN git clone https://github.com/veripool/vcddiff.git && \
#     make -C vcddiff && \
#     cp -p vcddiff/vcddiff /usr/local/bin/vcddiff && \
#     rm -rf vcddiff

# Creating work directory
ENV BUILD_DIR /work
RUN mkdir ${BUILD_DIR}

# Do some work
WORKDIR ${BUILD_DIR}
CMD ls -al / ; pwd ; verilator -lint-only -Wall /work/gateware/src/*.v