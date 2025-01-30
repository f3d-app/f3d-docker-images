FROM ubuntu:24.04 AS base

ARG CMAKE_BUILD_PARALLEL_LEVEL=8
ENV CMAKE_BUILD_PARALLEL_LEVEL=$CMAKE_BUILD_PARALLEL_LEVEL

ARG ANDROID_NDK
RUN [ -n "$ANDROID_NDK" ]

ARG ANDROID_API
RUN [ -n "$ANDROID_API" ]
ENV ANDROID_API=$ANDROID_API

ARG ANDROID_ARCH
RUN [ -n "$ANDROID_ARCH" ]
ENV ANDROID_ARCH=$ANDROID_ARCH

# Install generic compilation tools
RUN apt update && apt install -y \
      build-essential \
      cmake \
      default-jdk \
      git \
      unzip \
      wget

# Install NDK
RUN wget https://dl.google.com/android/repository/android-ndk-$ANDROID_NDK-linux.zip
RUN unzip -qq android-ndk-$ANDROID_NDK-linux.zip && rm -rf android-ndk-$ANDROID_NDK-linux.zip
RUN mv android-ndk-$ANDROID_NDK /ndk

# Copy toolchain
COPY android-toolchain.cmake /

######################################
# IMath
######################################
FROM base AS imath

ARG IMATH_VERSION
RUN [ -n "$IMATH_VERSION" ]

ADD https://github.com/AcademySoftwareFoundation/Imath/archive/refs/tags/$IMATH_VERSION.tar.gz /imath-src.tar.gz

RUN mkdir -p /imath-src && tar -xzf /imath-src.tar.gz -C /imath-src --strip-components 1 && rm -rf /imath-src.tar.gz

RUN cmake -S /imath-src -B /imath-build \
  -DBUILD_TESTING=OFF \
  -DBUILD_SHARED_LIBS==OFF \
  -DCMAKE_BUILD_TYPE=Release \
  -DCMAKE_TOOLCHAIN_FILE=/android-toolchain.cmake \
  -DCMAKE_INSTALL_PREFIX:PATH=/depends

RUN cmake --build /imath-build --target install && rm -rf /imath-src /imath-build
