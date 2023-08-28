FROM ubuntu:18.04

# Install dockerfile dependency
RUN apt update && apt install -y \
      ca-certificates \
      cargo \
      libssl-dev \
      pkg-config \
      software-properties-common \
      wget

# Install generic build dependency
RUN apt update && apt install -y \
      build-essential \
      g++-8 \
      gcc-8

# Install VTK build dependency
RUN apt update && apt install -y \
      libgl1-mesa-dev \
      libglfw3-dev \
      libglu1-mesa \
      libssl-dev \
      libx11-dev \
      libxcursor-dev \
      libxt-dev

# Install F3D build dependency
RUN apt update && apt install -y help2man

# Install superbuild dependencies
RUN apt update && apt install -y \
      chrpath \
      curl \
      gzip

# Install CI tools
RUN apt update && apt install -y xvfb

# Install up-to-date needed packages
RUN wget -O - https://apt.kitware.com/keys/kitware-archive-latest.asc 2>/dev/null | gpg --dearmor - | tee /etc/apt/trusted.gpg.d/kitware.gpg >/dev/null
RUN apt-add-repository 'deb https://apt.kitware.com/ubuntu/ bionic main'
RUN add-apt-repository ppa:git-core/ppa
RUN curl -s https://packagecloud.io/install/repositories/github/git-lfs/script.deb.sh | bash
RUN apt update && apt install -y cmake git git-lfs

# Install sccache
RUN cargo install sccache --version 0.4.2 --locked
ENV PATH="${PATH}:/root/.cargo/bin"

# Use gcc-8 by default
RUN update-alternatives --install /usr/bin/gcc gcc /usr/bin/gcc-8 800 --slave /usr/bin/g++ g++ /usr/bin/g++-8
