FROM ubuntu:26.04

# Install dockerfile dependency
RUN apt update && apt install -y \
      software-properties-common \
      wget

# Install generic build dependency
RUN apt update && apt install -y \
      build-essential \
      clang \
      cmake

# Install VTK and others build dependency
# file is needed for the superbuild
# libpng-dev is needed for clip
# bison, byacc, flex, pkg-config, ninja-build and libzstd-dev are needed for mesa
RUN apt update && apt install -y \
      file \
      libgl1-mesa-dev \
      libglfw3-dev \
      libglu1-mesa \
      libssl-dev \
      libx11-dev \
      libxcursor-dev \
      libxt-dev \
      libpng-dev \
      bison \
      byacc \
      flex \
      pkg-config \
      ninja-build \
      libzstd-dev \
      f3d

# Install F3D build and test dependency
RUN apt update && apt install -y \
      default-jdk \
      help2man \
      libboost-dev \
      python3-dev \
      libqt6opengl6-dev \
      qt6-declarative-dev \
      qml6-module-qtquick \
      qml6-module-qtquick-window \
      qml6-module-qtqml-workerscript \
      libfltk1.3-dev

# Install CI tools
RUN apt update && apt install -y \
      clang-tidy \
      cppcheck \
      git \
      git-lfs \
      lcov \
      wget \
      xvfb \
      curl \
      jq
