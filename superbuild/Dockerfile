FROM ubuntu:22.04

ARG DEBIAN_FRONTEND=noninteractive

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
      build-essential

# Install VTK build dependency
RUN apt update && apt install -y \
      libgl1-mesa-dev \
      libglfw3-dev \
      libglu1-mesa \
      libx11-dev \
      libxcursor-dev \
      libxt-dev

# Install F3D build dependency
RUN apt update && apt install -y \
      help2man \
      python3-dev

# Install superbuild dependencies
RUN apt update && apt install -y \
      chrpath \
      curl \
      gzip

# Install testing dependency
RUN apt update && apt install -y \
      libosmesa6-dev

# Install CI tools
RUN apt update && apt install -y \
      xvfb \
      git \
      git-lfs

# Install up-to-date needed packages
RUN wget -O - https://apt.kitware.com/keys/kitware-archive-latest.asc 2>/dev/null | gpg --dearmor - | tee /etc/apt/trusted.gpg.d/kitware.gpg >/dev/null
RUN apt-add-repository 'deb https://apt.kitware.com/ubuntu/ jammy main'
RUN apt update && apt install -y cmake=3.31.6-0kitware1ubuntu22.04.1 cmake-data=3.31.6-0kitware1ubuntu22.04.1

# Install sccache
RUN cargo install sccache --version 0.4.2 --locked
ENV PATH="${PATH}:/root/.cargo/bin"
