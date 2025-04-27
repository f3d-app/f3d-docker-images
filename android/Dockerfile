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
  -DBUILD_SHARED_LIBS=OFF \
  -DCMAKE_BUILD_TYPE=Release \
  -DCMAKE_TOOLCHAIN_FILE=/android-toolchain.cmake \
  -DCMAKE_INSTALL_PREFIX:PATH=/depends

RUN cmake --build /imath-build --target install && rm -rf /imath-src /imath-build

######################################
# Alembic
######################################
FROM imath AS alembic

ARG ALEMBIC_VERSION
RUN [ -n "$ALEMBIC_VERSION" ]

ADD https://github.com/alembic/alembic/archive/refs/tags/$ALEMBIC_VERSION.tar.gz /alembic-src.tar.gz

RUN mkdir -p /alembic-src && tar -xzf /alembic-src.tar.gz -C /alembic-src --strip-components 1 && rm -rf /alembic-src.tar.gz

RUN cmake -S /alembic-src -B /alembic-build \
  -DALEMBIC_LIB_INSTALL_DIR=lib \
  -DALEMBIC_SHARED_LIBS=OFF \
  -DCMAKE_BUILD_TYPE=Release \
  -DCMAKE_TOOLCHAIN_FILE=/android-toolchain.cmake \
  -DCMAKE_INSTALL_PREFIX:PATH=/depends \
  -DCMAKE_PREFIX_PATH:PATH=/depends \
  -DUSE_BINARIES=OFF \
  -DUSE_TESTS=OFF

RUN cmake --build /alembic-build --target install && rm -rf /alembic-src /alembic-build

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
  -DCMAKE_INSTALL_PREFIX:PATH=/depends \
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
  -DASSIMP_BUILD_ZLIB=OFF \
  -DASSIMP_NO_EXPORT=ON \
  -DASSIMP_WARNINGS_AS_ERRORS=OFF

RUN cmake --build /assimp-build --target install && rm -rf /assimp-src /assimp-build

######################################
# OCCT
######################################
FROM base AS occt

ARG OCCT_VERSION
RUN [ -n "$OCCT_VERSION" ]

ADD https://github.com/Open-Cascade-SAS/OCCT/archive/refs/tags/$OCCT_VERSION.tar.gz /occt-src.tar.gz

RUN mkdir -p /occt-src && tar -xzf /occt-src.tar.gz -C /occt-src --strip-components 1 && rm -rf /occt-src.tar.gz

RUN cmake -S /occt-src -B /occt-build \
  -DBUILD_SHARED_LIBS=OFF \
  -DCMAKE_TOOLCHAIN_FILE=/android-toolchain.cmake \
  -DCMAKE_BUILD_TYPE=Release \
  -DCMAKE_INSTALL_PREFIX:PATH=/depends \
  -DBUILD_ADDITIONAL_TOOLKITS="TKDESTEP;TKDEIGES;TKMesh;TKBinXCAF" \
  -DBUILD_DOC_Overview=OFF \
  -DBUILD_LIBRARY_TYPE=Static \
  -DBUILD_MODULE_ApplicationFramework=OFF \
  -DBUILD_MODULE_DETools=OFF \
  -DBUILD_MODULE_DataExchange=OFF \
  -DBUILD_MODULE_Draw=OFF \
  -DBUILD_MODULE_FoundationClasses=OFF \
  -DBUILD_MODULE_ModelingAlgorithms=OFF \
  -DBUILD_MODULE_ModelingData=OFF \
  -DBUILD_MODULE_Visualization=OFF \
  -DUSE_FREETYPE=OFF

RUN cmake --build /occt-build --target install && rm -rf /occt-src /occt-build

######################################
# Draco
######################################
FROM base AS draco

ARG CMAKE_BUILD_PARALLEL_LEVEL=8
ARG DRACO_VERSION
RUN [ -n "$DRACO_VERSION" ]

ADD https://github.com/google/draco/archive/refs/tags/$DRACO_VERSION.tar.gz /draco-src.tar.gz

RUN mkdir -p /draco-src && tar -xzf /draco-src.tar.gz -C /draco-src --strip-components 1 && rm -rf /draco-src.tar.gz

RUN cmake -S /draco-src -B /draco-build \
  -DBUILD_SHARED_LIBS=OFF \
  -DCMAKE_TOOLCHAIN_FILE=/android-toolchain.cmake \
  -DCMAKE_POSITION_INDEPENDENT_CODE=ON \
  -DCMAKE_BUILD_TYPE=Release \
  -DCMAKE_INSTALL_PREFIX:PATH=/depends \
  -DDRACO_BACKWARDS_COMPATIBILITY=OFF \
  -DDRACO_JS_GLUE=OFF

RUN cmake --build /draco-build --target install && rm -rf /draco-src /draco-build

######################################
# OpenEXR
######################################
FROM imath AS openexr

ARG CMAKE_BUILD_PARALLEL_LEVEL=8
ARG OPENEXR_VERSION
RUN [ -n "$OPENEXR_VERSION" ]

ADD https://github.com/AcademySoftwareFoundation/openexr/archive/refs/tags/$OPENEXR_VERSION.tar.gz /openexr-src.tar.gz

RUN mkdir -p /openexr-src && tar -xzf /openexr-src.tar.gz -C /openexr-src --strip-components 1 && rm -rf /openexr-src.tar.gz

RUN cmake -S /openexr-src -B /openexr-build \
  -DBUILD_TESTING=OFF \
  -DBUILD_SHARED_LIBS=OFF \
  -DCMAKE_TOOLCHAIN_FILE=/android-toolchain.cmake \
  -DCMAKE_BUILD_TYPE=Release \
  -DCMAKE_INSTALL_PREFIX:PATH=/depends \
  -DOPENEXR_BUILD_TOOLS=OFF \
  -DOPENEXR_BUILD_EXAMPLES=OFF

RUN cmake --build /openexr-build --target install && rm -rf /openexr-src /openexr-build

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
      -DVTK_ANDROID_BUILD=ON \
      -DVTK_ANDROID_USER_OPTIONS="-DVTK_MODULE_ENABLE_VTK_IOInfovis=NO;-DVTK_MODULE_ENABLE_VTK_RenderingLabel=NO;-DVTK_MODULE_ENABLE_VTK_TestingRendering=NO"

RUN cmake --build /vtk-build && rm -rf /vtk-src

######################################
# Copy artifacts from previous builds
######################################
FROM base

ENV CMAKE_TOOLCHAIN_FILE=/android-toolchain.cmake

COPY --from=alembic /depends /depends
COPY --from=assimp /depends /depends
COPY --from=draco /depends /depends
COPY --from=occt /depends /depends
COPY --from=openexr /depends /depends
COPY --from=vtk /vtk-build/CMakeExternals/Install/vtk-android /depends
