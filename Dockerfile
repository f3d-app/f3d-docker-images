FROM ubuntu:23.04

RUN apt update

# Install generic build dependency
RUN apt install -y \
      build-essential \
      cmake \
      clang

# Install VTK build dependency
RUN apt install -y \
      libgl1-mesa-dev \
      libglfw3-dev \
      libglu1-mesa \
      libssl-dev \
      libx11-dev \
      libxcursor-dev \
      libxt-dev

# Install F3D build and test dependency
RUN apt install -y \
      default-jdk \
      help2man \
      libqt5opengl5-dev \
      python3-dev

# Install CI tools
RUN apt install -y \
      git \
      git-lfs \
      lcov \
      xvfb
