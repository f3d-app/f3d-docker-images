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

# Install dockerfile dependency
RUN apt update && apt install -y \
      ca-certificates \
      jq \
      libssl-dev \
      pkg-config \
      software-properties-common \
      wget

# Install generic compilation tools
RUN apt update && apt install -y \
      build-essential \
      default-jdk \
      git \
      unzip

# Install up-to-date needed packages
RUN wget -O - https://apt.kitware.com/keys/kitware-archive-latest.asc 2>/dev/null | gpg --dearmor - | tee /etc/apt/trusted.gpg.d/kitware.gpg >/dev/null
RUN apt-add-repository 'deb https://apt.kitware.com/ubuntu/ noble main'
RUN apt update && apt install -y cmake=3.31.6-0kitware1ubuntu24.04.1 cmake-data=3.31.6-0kitware1ubuntu24.04.1

# Install NDK
RUN wget https://dl.google.com/android/repository/android-ndk-$ANDROID_NDK-linux.zip
RUN unzip -qq android-ndk-$ANDROID_NDK-linux.zip && rm -rf android-ndk-$ANDROID_NDK-linux.zip
RUN mv android-ndk-$ANDROID_NDK /ndk

# Copy toolchain
COPY android-toolchain.cmake /

# Copy F3D version.json
ADD https://raw.githubusercontent.com/f3d-app/f3d/refs/heads/master/.github/workflows/versions.json /versions.json

######################################
# openjph
######################################
FROM base AS openjph

ARG OPENJPH_VERSION
RUN OPENJPH_VERSION=${OPENJPH_VERSION:-$(jq -r '.openjph.version' /versions.json)} \
  && wget -q https://github.com/aous72/openjph/archive/refs/tags/$OPENJPH_VERSION.tar.gz -O /openjph-src.tar.gz

RUN mkdir -p /openjph-src && tar -xzf /openjph-src.tar.gz -C /openjph-src --strip-components 1 && rm -rf /openjph-src.tar.gz

RUN cmake -S /openjph-src -B /openjph-build \
  -DBUILD_TESTING=OFF \
  -DBUILD_SHARED_LIBS=OFF \
  -DCMAKE_BUILD_TYPE=Release \
  -DCMAKE_INSTALL_PREFIX:PATH=/depends \
  -DCMAKE_TOOLCHAIN_FILE=/android-toolchain.cmake \
  -DOJPH_ENABLE_TIFF_SUPPORT=OFF \
  -DUSE_TIFF=OFF

RUN cmake --build /openjph-build --target install && rm -rf /openjph-src /openjph-build

######################################
# IMath
######################################
FROM base AS imath

ARG IMATH_VERSION
RUN IMATH_VERSION=${IMATH_VERSION:-$(jq -r '.imath.version' /versions.json)} \
  && wget -q https://github.com/AcademySoftwareFoundation/Imath/archive/refs/tags/$IMATH_VERSION.tar.gz -O /imath-src.tar.gz

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
FROM base AS alembic

ARG ALEMBIC_VERSION
RUN ALEMBIC_VERSION=${ALEMBIC_VERSION:-$(jq -r '.alembic.version' /versions.json)} \
  && wget -q https://github.com/alembic/alembic/archive/refs/tags/$ALEMBIC_VERSION.tar.gz -O /alembic-src.tar.gz

RUN mkdir -p /alembic-src && tar -xzf /alembic-src.tar.gz -C /alembic-src --strip-components 1 && rm -rf /alembic-src.tar.gz

COPY --from=imath /depends /depends

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
RUN ASSIMP_VERSION=${ASSIMP_VERSION:-$(jq -r '.assimp.version' /versions.json)} \
  && wget -q https://github.com/assimp/assimp/archive/refs/tags/$ASSIMP_VERSION.tar.gz -O /assimp-src.tar.gz

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
RUN OCCT_VERSION=${OCCT_VERSION:-$(jq -r '.occt.version' /versions.json)} \
  && wget -q https://github.com/Open-Cascade-SAS/OCCT/archive/refs/tags/$OCCT_VERSION.tar.gz -O /occt-src.tar.gz

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

ARG DRACO_VERSION
RUN DRACO_VERSION=${DRACO_VERSION:-$(jq -r '.draco.version' /versions.json)} \
  && wget -q https://github.com/google/draco/archive/refs/tags/$DRACO_VERSION.tar.gz -O /draco-src.tar.gz

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
FROM base AS openexr

ARG OPENEXR_VERSION
RUN OPENEXR_VERSION=${OPENEXR_VERSION:-$(jq -r '.openexr.version' /versions.json)} \
  && wget -q https://github.com/AcademySoftwareFoundation/openexr/archive/refs/tags/$OPENEXR_VERSION.tar.gz -O /openexr-src.tar.gz

RUN mkdir -p /openexr-src && tar -xzf /openexr-src.tar.gz -C /openexr-src --strip-components 1 && rm -rf /openexr-src.tar.gz

COPY --from=imath /depends /depends
COPY --from=openjph /depends /depends

RUN cmake -S /openexr-src -B /openexr-build \
  -DBUILD_TESTING=OFF \
  -DBUILD_SHARED_LIBS=OFF \
  -DCMAKE_BUILD_TYPE=Release \
  -DCMAKE_INSTALL_PREFIX:PATH=/depends \
  -DCMAKE_TOOLCHAIN_FILE=/android-toolchain.cmake \
  -DOPENEXR_BUILD_EXAMPLES=OFF \
  -DOPENEXR_BUILD_TOOLS=OFF \
  -DOPENEXR_FORCE_INTERNAL_OPENJPH=OFF

RUN cmake --build /openexr-build --target install && rm -rf /openexr-src /openexr-build

######################################
# TBB
######################################
FROM base AS tbb

ARG TBB_VERSION
RUN TBB_VERSION=${TBB_VERSION:-$(jq -r '.tbb.version' /versions.json)} \
  && wget -q https://github.com/oneapi-src/oneTBB/archive/refs/tags/$TBB_VERSION.tar.gz -O /tbb-src.tar.gz

RUN mkdir -p /tbb-src && tar -xzf /tbb-src.tar.gz -C /tbb-src --strip-components 1 && rm -rf /tbb-src.tar.gz

RUN cmake -S /tbb-src -B /tbb-build \
  -DBUILD_TESTING=OFF \
  -DBUILD_SHARED_LIBS=OFF \
  -DCMAKE_TOOLCHAIN_FILE=/android-toolchain.cmake \
  -DCMAKE_BUILD_TYPE=Release \
  -DCMAKE_INSTALL_PREFIX:PATH=/depends \
  -DTBB_STRICT=OFF \
  -DTBB_TEST=OFF \
  -DTBB4PY_BUILD=OFF

RUN cmake --build /tbb-build --target install && rm -rf /tbb-src /tbb-build

######################################
# blosc
######################################
FROM base AS blosc

ARG BLOSC_VERSION
RUN BLOSC_VERSION=${BLOSC_VERSION:-$(jq -r '.blosc.version' /versions.json)} \
  && wget -q https://github.com/Blosc/c-blosc/archive/refs/tags/$BLOSC_VERSION.tar.gz -O /blosc-src.tar.gz

RUN mkdir -p /blosc-src && tar -xzf /blosc-src.tar.gz -C /blosc-src --strip-components 1 && rm -rf /blosc-src.tar.gz

RUN cmake -S /blosc-src -B /blosc-build \
  -DCMAKE_TOOLCHAIN_FILE=/android-toolchain.cmake \
  -DCMAKE_BUILD_TYPE=Release \
  -DCMAKE_INSTALL_PREFIX:PATH=/depends \
  -DBUILD_BENCHMARKS=OFF \
  -DBUILD_FUZZERS=OFF \
  -DBUILD_SHARED=OFF \
  -DBUILD_STATIC=ON \
  -DBUILD_TESTS=OFF \
  -DPREFER_EXTERNAL_ZLIB=ON \
  -DDEACTIVATE_LZ4=ON

RUN cmake --build /blosc-build --target install && rm -rf /blosc-src /blosc-build

######################################
# OpenVDB
######################################
FROM base AS openvdb

ARG OPENVDB_VERSION
RUN OPENVDB_VERSION=${OPENVDB_VERSION:-$(jq -r '.openvdb.version' /versions.json)} \
  && wget -q https://github.com/AcademySoftwareFoundation/openvdb/archive/refs/tags/$OPENVDB_VERSION.tar.gz -O /openvdb-src.tar.gz

RUN mkdir -p /openvdb-src && tar -xzf /openvdb-src.tar.gz -C /openvdb-src --strip-components 1 && rm -rf /openvdb-src.tar.gz

COPY openvdb-remove-not-needed-cmake-modules.patch /
RUN patch -p1 -d /openvdb-src < /openvdb-remove-not-needed-cmake-modules.patch

COPY openvdb-fix-visible-dependencies-link.patch /
RUN patch -p1 -d /openvdb-src < /openvdb-fix-visible-dependencies-link.patch

COPY --from=tbb /depends /depends
COPY --from=blosc /depends /depends

RUN cmake -S /openvdb-src -B /openvdb-build \
  -DCMAKE_TOOLCHAIN_FILE=/android-toolchain.cmake \
  -DCMAKE_BUILD_TYPE=Release \
  -DCMAKE_INSTALL_PREFIX:PATH=/depends \
  -DCMAKE_PREFIX_PATH:PATH=/depends \
  -DCMAKE_POSITION_INDEPENDENT_CODE=ON \
  -DDISABLE_DEPENDENCY_VERSION_CHECKS=ON \
  -DOPENVDB_BUILD_BINARIES=OFF \
  -DOPENVDB_BUILD_VDB_PRINT=OFF \
  -DOPENVDB_CORE_SHARED=OFF \
  -DOPENVDB_CORE_STATIC=ON \
  -DOPENVDB_USE_DELAYED_LOADING=OFF \
  -DUSE_BLOSC=ON \
  -DUSE_CCACHE=OFF \
  -DUSE_EXPLICIT_INSTANTIATION=OFF \
  -DUSE_ZLIB=ON

RUN cmake --build /openvdb-build --target install && rm -rf /openvdb-src /openvdb-build

######################################
# OpenUSD
######################################
FROM base AS openusd

ARG ANDROID_ARCH
ARG OPENUSD_VERSION
RUN OPENUSD_VERSION=${OPENUSD_VERSION:-$(jq -r '.usd.version' /versions.json)} \
  && wget -q https://github.com/PixarAnimationStudios/OpenUSD/archive/refs/tags/$OPENUSD_VERSION.tar.gz -O /openusd-src.tar.gz

RUN mkdir -p /openusd-src && tar -xzf /openusd-src.tar.gz -C /openusd-src --strip-components 1 && rm -rf /openusd-src.tar.gz

COPY openusd-fix-compile.patch /
RUN patch -p1 -d /openusd-src < /openusd-fix-compile.patch

COPY --from=tbb /depends /depends

RUN if [ "$ANDROID_ARCH" != "x86" ] && [ "$ANDROID_ARCH" != "armeabi-v7a" ]; then \
  cmake -S /openusd-src -B /openusd-build \
    -DBUILD_TESTING=OFF \
    -DBUILD_SHARED_LIBS=OFF \
    -DCMAKE_TOOLCHAIN_FILE=/android-toolchain.cmake \
    -DCMAKE_BUILD_TYPE=Release \
    -DCMAKE_INSTALL_PREFIX:PATH=/depends \
    -DCMAKE_PREFIX_PATH:PATH=/depends \
    -DPXR_BUILD_EXAMPLES:BOOL=OFF \
    -DPXR_BUILD_IMAGING:BOOL=OFF \
    -DPXR_BUILD_MONOLITHIC:BOOL=ON \
    -DPXR_BUILD_TESTS:BOOL=OFF \
    -DPXR_BUILD_TUTORIALS:BOOL=OFF \
    -DPXR_BUILD_USD_TOOLS:BOOL=OFF \
    -DPXR_ENABLE_GL_SUPPORT:BOOL=OFF \
    -DPXR_ENABLE_PRECOMPILED_HEADERS:BOOL=OFF \
    -DPXR_ENABLE_PYTHON_SUPPORT:BOOL=OFF \
    -DPXR_INSTALL_LOCATION:STRING=../lib/usd; \
  fi

RUN if [ "$ANDROID_ARCH" != "x86" ] && [ "$ANDROID_ARCH" != "armeabi-v7a" ]; then \
  cmake --build /openusd-build --target install && rm -rf /openusd-src /openusd-build; \
  fi

######################################
# WebP
######################################
FROM base AS webp

ARG WEBP_VERSION
RUN WEBP_VERSION=${WEBP_VERSION:-$(jq -r '.webp.version' /versions.json)} \
  && wget -q https://github.com/webmproject/libwebp/archive/refs/tags/$WEBP_VERSION.tar.gz -O /webp-src.tar.gz

RUN mkdir -p /webp-src && tar -xzf /webp-src.tar.gz -C /webp-src --strip-components 1 && rm -rf /webp-src.tar.gz

RUN cmake -S /webp-src -B /webp-build \
  -DANDROID_NDK=/ndk \
  -DBUILD_TESTING=OFF \
  -DBUILD_SHARED_LIBS=OFF \
  -DCMAKE_TOOLCHAIN_FILE=/android-toolchain.cmake \
  -DCMAKE_BUILD_TYPE=Release \
  -DCMAKE_INSTALL_PREFIX:PATH=/depends \
  -DWEBP_BUILD_ANIM_UTILS=OFF \
  -DWEBP_BUILD_CWEBP=OFF \
  -DWEBP_BUILD_DWEBP=OFF \
  -DWEBP_BUILD_GIF2WEBP=OFF \
  -DWEBP_BUILD_IMG2WEBP=OFF \
  -DWEBP_BUILD_VWEBP=OFF \
  -DWEBP_BUILD_WEBPINFO=OFF \
  -DWEBP_BUILD_LIBWEBPMUX=OFF \
  -DWEBP_BUILD_WEBPMUX=OFF \
  -DWEBP_BUILD_EXTRAS=OFF

RUN cmake --build /webp-build --target install && rm -rf /webp-src /webp-build

######################################
# web-ifc
######################################
FROM base AS webifc

ARG WEBIFC_VERSION
RUN WEBIFC_VERSION=${WEBIFC_VERSION:-$(jq -r '.webifc.version' /versions.json)} \
  && wget -q https://github.com/ThatOpen/engine_web-ifc/archive/refs/tags/$WEBIFC_VERSION.tar.gz -O /webifc-src.tar.gz

RUN mkdir -p /webifc-src && tar -xzf /webifc-src.tar.gz -C /webifc-src --strip-components 1 && rm -rf /webifc-src.tar.gz

COPY webifc-remove-std-format.patch /
RUN patch -p1 -d /webifc-src < /webifc-remove-std-format.patch

RUN cmake -S /webifc-src/src/cpp -B /webifc-build \
  -DBUILD_SHARED_LIBS=OFF \
  -DCMAKE_TOOLCHAIN_FILE=/android-toolchain.cmake \
  -DCMAKE_POSITION_INDEPENDENT_CODE=ON \
  -DCMAKE_BUILD_TYPE=Release \
  -DCMAKE_INSTALL_PREFIX:PATH=/depends

RUN cmake --build /webifc-build --target install && rm -rf /webifc-src /webifc-build

######################################
# VTK
######################################
FROM base AS vtk

ARG VTK_VERSION
RUN VTK_VERSION=${VTK_VERSION:-$(jq -r '.vtk_commit_sha' /versions.json)} \
  && wget -q https://gitlab.kitware.com/vtk/vtk/-/archive/$VTK_VERSION/vtk-$VTK_VERSION.tar.gz -O /vtk-src.tar.gz

RUN mkdir -p /vtk-src && tar -xzf /vtk-src.tar.gz -C /vtk-src --strip-components 1 && rm -rf /vtk-src.tar.gz

COPY vtk-netcdf-mremap.patch /
RUN patch -p1 -d /vtk-src < /vtk-netcdf-mremap.patch

COPY --from=openvdb /depends /depends

# OPENVDB_USE_STATIC_LIBS is needed because FindOpenVDB.cmake is not smart enough to find it out itself
# CMAKE_MODULE_PATH is needed because of https://github.com/AcademySoftwareFoundation/openvdb/issues/1160
ENV OPENVDB_ADDITIONAL_OPTIONS="-DCMAKE_MODULE_PATH=/depends/lib/cmake/OpenVDB;-DOPENVDB_USE_STATIC_LIBS=ON"

RUN cmake -S /vtk-src -B /vtk-build \
      -DANDROID_ARCH_ABI=$ANDROID_ARCH \
      -DANDROID_NATIVE_API_LEVEL=$ANDROID_API \
      -DANDROID_NDK=/ndk \
      -DCMAKE_BUILD_TYPE=Release \
      -DVTK_ANDROID_BUILD=ON \
      -DVTK_ANDROID_USER_OPTIONS="-DCMAKE_FIND_ROOT_PATH:PATH=/depends;${OPENVDB_ADDITIONAL_OPTIONS};-DVTK_MODULE_ENABLE_VTK_IOInfovis=NO;-DVTK_MODULE_ENABLE_VTK_IOOpenVDB=YES;-DVTK_MODULE_ENABLE_VTK_IOHDF=YES;-DVTK_MODULE_ENABLE_VTK_IOExodus=YES;-DVTK_MODULE_ENABLE_VTK_IONetCDF=YES;-DVTK_MODULE_ENABLE_VTK_RenderingLabel=NO;-DVTK_MODULE_ENABLE_VTK_TestingRendering=NO;-DVTK_MODULE_ENABLE_VTK_RenderingGridAxes=YES"

RUN cmake --build /vtk-build && rm -rf /vtk-src

######################################
# Copy artifacts from previous builds
######################################
FROM base AS final

ENV CMAKE_TOOLCHAIN_FILE=/android-toolchain.cmake

COPY --from=alembic /depends /depends
COPY --from=assimp /depends /depends
COPY --from=draco /depends /depends
COPY --from=occt /depends /depends
COPY --from=openexr /depends /depends
COPY --from=openusd /depends /depends
COPY --from=openvdb /depends /depends
COPY --from=webp /depends /depends
COPY --from=webifc /depends /depends
COPY --from=vtk /vtk-build/CMakeExternals/Install/vtk-android /depends
