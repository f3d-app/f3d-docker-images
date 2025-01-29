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
RUN unzip -qq android-ndk-$ANDROID_NDK-linux.zip
RUN mv android-ndk-$ANDROID_NDK /ndk

# Copy toolchain
COPY android-toolchain.cmake /

######################################
# Assimp
######################################
FROM base AS assimp

ARG ASSIMP_VERSION
RUN [ -n "$ASSIMP_VERSION" ]

ADD https://github.com/assimp/assimp/archive/refs/tags/$ASSIMP_VERSION.tar.gz /assimp-src.tar.gz

RUN mkdir -p /assimp-src && tar -xzf /assimp-src.tar.gz -C /assimp-src --strip-components 1 && rm -rf /assimp-src.tar.gz

RUN cmake -S /assimp-src -B /assimp-build \
  -DBUILD_SHARED_LIBS=OFF \
  -DCMAKE_TOOLCHAIN_FILE=/android-toolchain.cmake \
  -DCMAKE_BUILD_TYPE=Release \
  -DCMAKE_INSTALL_PREFIX:PATH=/depends/$ANDROID_ARCH \
  -DASSIMP_BUILD_ALL_IMPORTERS_BY_DEFAULT=OFF \
  -DASSIMP_BUILD_ASSIMP_TOOLS=OFF \
  -DASSIMP_BUILD_3MF_IMPORTER=ON \
  -DASSIMP_BUILD_COLLADA_IMPORTER=ON \
  -DASSIMP_BUILD_DXF_IMPORTER=ON \
  -DASSIMP_BUILD_FBX_IMPORTER=ON \
  -DASSIMP_BUILD_OFF_IMPORTER=ON \
  -DASSIMP_BUILD_X_IMPORTER=ON \
  -DASSIMP_BUILD_SAMPLES=OFF \
  -DASSIMP_BUILD_TESTS=OFF \
  -DASSIMP_BUILD_ZLIB=ON \
  -DASSIMP_NO_EXPORT=ON \
  -DASSIMP_WARNINGS_AS_ERRORS=OFF

RUN cmake --build /assimp-build --target install && rm -rf /assimp-src /assimp-build

######################################
# VTK
######################################
FROM base AS vtk

ARG VTK_VERSION
RUN [ -n "$VTK_VERSION" ]

ADD https://gitlab.kitware.com/vtk/vtk/-/archive/$VTK_VERSION/vtk-$VTK_VERSION.tar.gz /vtk-src.tar.gz

RUN mkdir -p /vtk-src && tar -xzf /vtk-src.tar.gz -C /vtk-src --strip-components 1 && rm -rf /vtk-src.tar.gz

RUN cmake -S /vtk-src -B /vtk-build \
      -DANDROID_ARCH_ABI=$ANDROID_ARCH \
      -DANDROID_NATIVE_API_LEVEL=$ANDROID_API \
      -DANDROID_NDK=/ndk \
      -DCMAKE_BUILD_TYPE=Release \
      -DVTK_ANDROID_BUILD=ON

RUN cmake --build /vtk-build && rm -rf /vtk-src

######################################
# Copy artifacts from previous builds
######################################
FROM base

ENV CMAKE_TOOLCHAIN_FILE /android-toolchain.cmake

COPY --from=assimp /depends/$ANDROID_ARCH /depends/$ANDROID_ARCH
COPY --from=vtk /vtk-build/CMakeExternals/Install/vtk-android /depends/$ANDROID_ARCH
