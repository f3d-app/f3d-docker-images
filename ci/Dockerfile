FROM ubuntu:24.04

# Install dockerfile dependency
RUN apt update && apt install -y \
      software-properties-common \
      wget

# Install generic build dependency
RUN apt update && apt install -y \
      build-essential \
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
      libqt6opengl6-dev \
      qt6-declarative-dev \
      qml6-module-qtquick \
      qml6-module-qtquick-window \
      qml6-module-qtqml-workerscript

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

# Install up-to-date needed packages
RUN wget -O - https://apt.kitware.com/keys/kitware-archive-latest.asc 2>/dev/null | gpg --dearmor - | tee /etc/apt/trusted.gpg.d/kitware.gpg >/dev/null
RUN apt-add-repository 'deb https://apt.kitware.com/ubuntu/ noble main'
RUN apt update && apt install -y cmake=3.31.6-0kitware1ubuntu24.04.1 cmake-data=3.31.6-0kitware1ubuntu24.04.1
