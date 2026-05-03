FROM ubuntu:24.04

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
      build-essential \
      cmake

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
      file \
      gzip

# Install testing dependency
RUN apt update && apt install -y \
      libosmesa6-dev

# Install CI tools
RUN apt update && apt install -y \
      xvfb \
      git \
      git-lfs \
      jq

# Install sccache
RUN cargo install sccache --version 0.4.2 --locked
ENV PATH="${PATH}:/root/.cargo/bin"
