FROM ubuntu:22.04

# Install generic build dependency
RUN apt update && apt install -y \
      build-essential \
      cmake \
      clang

# Install VTK build dependency
RUN apt update && apt install -y \
      libosmesa6-dev \
      libgl1-mesa-dev \
      libglfw3-dev \
      libglu1-mesa \
      libssl-dev \
      libx11-dev \
      libxcursor-dev \
      libxt-dev

# Install F3D build and test dependency
RUN apt update && apt install -y \
      default-jdk \
      help2man \
      libboost-dev \
      libqt5opengl5-dev \
      python3-dev \
      xdotool

# Install CI tools
RUN apt update && apt install -y \
      clang-tidy \
      cppcheck \
      git \
      git-lfs \
      lcov \
      wget \
      xvfb
