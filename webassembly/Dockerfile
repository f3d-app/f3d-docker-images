FROM debian:stable-slim AS base

# Install generic build dependency
RUN apt update && apt install -y \
      build-essential \
      cmake \
      jq \
      ninja-build \
      python3 \
      nodejs \
      node-typescript \
      wget

# Install CI tools
RUN apt update && apt install -y \
      git \
      git-lfs \
      chromium \
      xvfb \
      dbus-x11

# Install Emscripten SDK
ADD https://github.com/emscripten-core/emsdk/archive/refs/tags/6.0.13.tar.gz /emsdk.tar.gz

RUN mkdir -p /emsdk && tar -xzf /emsdk.tar.gz -C /emsdk --strip-components 1 && rm -rf /emsdk.tar.gz

RUN /emsdk/emsdk install latest

# Configure build environment variables
ENV CMAKE_GENERATOR=Ninja
ENV CMAKE_TOOLCHAIN_FILE=/emsdk/upstream/emscripten/cmake/Modules/Platform/Emscripten.cmake
ENV PATH=/emsdk/upstream/bin:/emsdk/upstream/emscripten:$PATH
ENV CXXFLAGS=-fwasm-exceptions

# Copy F3D version.json
ADD https://raw.githubusercontent.com/f3d-app/f3d/refs/heads/master/.github/workflows/versions.json /versions.json

######################################
# Zlib
######################################
FROM base AS zlib

ARG CMAKE_BUILD_PARALLEL_LEVEL=8
ARG ZLIB_VERSION
RUN ZLIB_VERSION=${ZLIB_VERSION:-$(jq -r '.zlib.version' /versions.json)} \
  && wget -q https://github.com/madler/zlib/archive/refs/tags/$ZLIB_VERSION.tar.gz -O /zlib-src.tar.gz

RUN mkdir -p /zlib-src && tar -xzf /zlib-src.tar.gz -C /zlib-src --strip-components 1 && rm -rf /zlib-src.tar.gz

RUN cmake -S /zlib-src -B /zlib-build \
  -DBUILD_SHARED_LIBS=OFF \
  -DCMAKE_BUILD_TYPE=Release \
  -DCMAKE_INSTALL_PREFIX:PATH=/depends

RUN cmake --build /zlib-build --target install && rm -rf /zlib-src /zlib-build

RUN rm -rf /depends/lib/libz.so*

######################################
# LZ4
######################################
FROM base AS lz4

ARG CMAKE_BUILD_PARALLEL_LEVEL=8
ARG LZ4_VERSION=v1.10.0
RUN LZ4_VERSION=${LZ4_VERSION:-$(jq -r '.lz4.version' /versions.json)} \
  && wget -q https://github.com/lz4/lz4/archive/refs/tags/$LZ4_VERSION.tar.gz -O /lz4-src.tar.gz

RUN mkdir -p /lz4-src && tar -xzf /lz4-src.tar.gz -C /lz4-src --strip-components 1 && rm -rf /lz4-src.tar.gz

RUN cmake -S /lz4-src/build/cmake -B /lz4-build \
  -DBUILD_SHARED_LIBS=OFF \
  -DBUILD_STATIC_LIBS=ON \
  -DBUILD_TESTING:BOOL=OFF \
  -DCMAKE_BUILD_TYPE=Release \
  -DCMAKE_INSTALL_PREFIX:PATH=/depends \
  -DCMAKE_INSTALL_LIBDIR:PATH=lib \
  -DLZ4_BUILD_CLI:BOOL=OFF \
  -DLZ4_BUILD_LEGACY_LZ4C:BOOL=OFF

RUN cmake --build /lz4-build --target install && rm -rf /lz4-src /lz4-build

######################################
# Assimp
######################################
FROM base AS assimp

COPY --from=zlib /depends /depends

ARG CMAKE_BUILD_PARALLEL_LEVEL=8
ARG ASSIMP_VERSION
RUN ASSIMP_VERSION=${ASSIMP_VERSION:-$(jq -r '.assimp.version' /versions.json)} \
  && wget -q https://github.com/assimp/assimp/archive/refs/tags/$ASSIMP_VERSION.tar.gz -O /assimp-src.tar.gz

RUN mkdir -p /assimp-src && tar -xzf /assimp-src.tar.gz -C /assimp-src --strip-components 1 && rm -rf /assimp-src.tar.gz

# https://github.com/assimp/assimp/pull/6753
COPY assimp-fix-amf-leak.patch /
RUN patch -p1 -d /assimp-src < /assimp-fix-amf-leak.patch

RUN cmake -S /assimp-src -B /assimp-build \
  -DBUILD_SHARED_LIBS=OFF \
  -DCMAKE_BUILD_TYPE=Release \
  -DCMAKE_INSTALL_PREFIX:PATH=/depends \
  -DCMAKE_FIND_ROOT_PATH:PATH=/depends \
  -DASSIMP_BUILD_ALL_IMPORTERS_BY_DEFAULT=OFF \
  -DASSIMP_BUILD_ASSIMP_TOOLS=OFF \
  -DASSIMP_BUILD_3MF_IMPORTER=ON \
  -DASSIMP_BUILD_AMF_IMPORTER=ON \
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
# TBB
######################################
FROM base AS tbb

ARG CMAKE_BUILD_PARALLEL_LEVEL=8
ARG TBB_VERSION
RUN TBB_VERSION=${TBB_VERSION:-$(jq -r '.tbb.version' /versions.json)} \
  && wget -q https://github.com/oneapi-src/oneTBB/archive/refs/tags/$TBB_VERSION.tar.gz -O /tbb-src.tar.gz

RUN mkdir -p /tbb-src && tar -xzf /tbb-src.tar.gz -C /tbb-src --strip-components 1 && rm -rf /tbb-src.tar.gz

RUN cmake -S /tbb-src -B /tbb-build \
  -DBUILD_SHARED_LIBS=OFF \
  -DCMAKE_BUILD_TYPE=Release \
  -DCMAKE_INSTALL_PREFIX:PATH=/depends \
  -DTBB_STRICT=OFF \
  -DTBB_TEST=OFF \
  -DTBB4PY_BUILD=OFF

RUN cmake --build /tbb-build --target install && rm -rf /tbb-src /tbb-build

######################################
# Blosc
######################################
FROM base AS blosc

COPY --from=lz4 /depends /depends
COPY --from=zlib /depends /depends

ARG CMAKE_BUILD_PARALLEL_LEVEL=8
ARG BLOSC_VERSION
RUN BLOSC_VERSION=${BLOSC_VERSION:-$(jq -r '.blosc.version' /versions.json)} \
  && wget -q https://github.com/Blosc/c-blosc/archive/refs/tags/$BLOSC_VERSION.tar.gz -O /blosc-src.tar.gz

RUN mkdir -p /blosc-src && tar -xzf /blosc-src.tar.gz -C /blosc-src --strip-components 1 && rm -rf /blosc-src.tar.gz

RUN cmake -S /blosc-src -B /blosc-build \
  -DBUILD_SHARED_LIBS=OFF \
  -DCMAKE_BUILD_TYPE=Release \
  -DCMAKE_INSTALL_PREFIX:PATH=/depends \
  -DBUILD_BENCHMARKS=OFF \
  -DBUILD_FUZZERS=OFF \
  -DBUILD_SHARED=OFF \
  -DBUILD_STATIC=ON \
  -DBUILD_TESTS=OFF \
  -DPREFER_EXTERNAL_LZ4=ON \
  -DPREFER_EXTERNAL_ZLIB=ON

RUN cmake --build /blosc-build --target install && rm -rf /blosc-src /blosc-build

######################################
# OpenVDB
######################################
FROM base AS openvdb

COPY --from=blosc /depends /depends
COPY --from=tbb /depends /depends

ARG CMAKE_BUILD_PARALLEL_LEVEL=8
ARG OPENVDB_VERSION
RUN OPENVDB_VERSION=${OPENVDB_VERSION:-$(jq -r '.openvdb.version' /versions.json)} \
  && wget -q https://github.com/AcademySoftwareFoundation/openvdb/archive/refs/tags/$OPENVDB_VERSION.tar.gz -O /openvdb-src.tar.gz

RUN mkdir -p /openvdb-src && tar -xzf /openvdb-src.tar.gz -C /openvdb-src --strip-components 1 && rm -rf /openvdb-src.tar.gz

RUN rm /openvdb-src/cmake/FindTBB.cmake

# Remove not needed CMake modules from OpenVDB
COPY openvdb-remove-not-needed-cmake-modules.patch /
RUN patch -p1 -d /openvdb-src < /openvdb-remove-not-needed-cmake-modules.patch

COPY openvdb-fix-visible-dependencies-link.patch /
RUN patch -p1 -d /openvdb-src < /openvdb-fix-visible-dependencies-link.patch

RUN ls /depends/lib/cmake && cmake -S /openvdb-src -B /openvdb-build \
  -DBUILD_SHARED_LIBS=OFF \
  -DCMAKE_BUILD_TYPE=Release \
  -DCMAKE_INSTALL_PREFIX:PATH=/depends \
  -DCMAKE_INSTALL_LIBDIR:PATH=lib \
  -DCMAKE_FIND_ROOT_PATH:PATH=/depends \
  -DOPENVDB_BUILD_BINARIES=OFF \
  -DOPENVDB_BUILD_VDB_PRINT:BOOL=OFF \
  -DOPENVDB_CORE_SHARED=OFF \
  -DOPENVDB_CORE_STATIC=ON \
  -DOPENVDB_USE_DELAYED_LOADING=OFF \
  -DUSE_BLOSC:BOOL=ON \
  -DUSE_CCACHE:BOOL=OFF \
  -DUSE_EXPLICIT_INSTANTIATION:BOOL=OFF \
  -DUSE_ZLIB:BOOL=ON

RUN cmake --build /openvdb-build --target install && rm -rf /openvdb-src /openvdb-build

######################################
# OCCT
######################################
FROM base AS occt

ARG CMAKE_BUILD_PARALLEL_LEVEL=8
ARG OCCT_VERSION
RUN OCCT_VERSION=${OCCT_VERSION:-$(jq -r '.occt.version' /versions.json)} \
  && wget -q https://github.com/Open-Cascade-SAS/OCCT/archive/refs/tags/$OCCT_VERSION.tar.gz -O /occt-src.tar.gz

RUN mkdir -p /occt-src && tar -xzf /occt-src.tar.gz -C /occt-src --strip-components 1 && rm -rf /occt-src.tar.gz

# By default OCCT converts exception to long jump on Unix
# This patch removes the macro used to enabled this feature
COPY occt-exception.patch /
RUN patch -p1 -d /occt-src < /occt-exception.patch

RUN cmake -S /occt-src -B /occt-build \
  -DBUILD_SHARED_LIBS=OFF \
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
  -DINSTALL_DIR_BIN:PATH=bin \
  -DUSE_FREETYPE=OFF

RUN cmake --build /occt-build --target install && rm -rf /occt-src /occt-build

######################################
# Draco
######################################
FROM base AS draco

ARG CMAKE_BUILD_PARALLEL_LEVEL=8
ARG DRACO_VERSION
RUN DRACO_VERSION=${DRACO_VERSION:-$(jq -r '.draco.version' /versions.json)} \
  && wget -q https://github.com/google/draco/archive/refs/tags/$DRACO_VERSION.tar.gz -O /draco-src.tar.gz

RUN mkdir -p /draco-src && tar -xzf /draco-src.tar.gz -C /draco-src --strip-components 1 && rm -rf /draco-src.tar.gz

# Draco requires EMSCRIPTEN env variable pointing to a valid path even if it's unused... so we give the root
RUN EMSCRIPTEN=/ cmake -S /draco-src -B /draco-build \
  -DBUILD_SHARED_LIBS=OFF \
  -DCMAKE_BUILD_TYPE=Release \
  -DCMAKE_INSTALL_PREFIX:PATH=/depends \
  -DDRACO_BACKWARDS_COMPATIBILITY=OFF \
  -DDRACO_JS_GLUE=OFF

RUN cmake --build /draco-build --target install && rm -rf /draco-src /draco-build

######################################
# WebP
######################################
FROM base AS webp

ARG CMAKE_BUILD_PARALLEL_LEVEL=8
ARG WEBP_VERSION
RUN WEBP_VERSION=${WEBP_VERSION:-$(jq -r '.webp.version' /versions.json)} \
  && wget -q https://github.com/webmproject/libwebp/archive/refs/tags/$WEBP_VERSION.tar.gz -O /webp-src.tar.gz

RUN mkdir -p /webp-src && tar -xzf /webp-src.tar.gz -C /webp-src --strip-components 1 && rm -rf /webp-src.tar.gz

RUN cmake -S /webp-src -B /webp-build \
  -DBUILD_SHARED_LIBS=OFF \
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

ARG CMAKE_BUILD_PARALLEL_LEVEL=8
ARG WEBIFC_VERSION
RUN WEBIFC_VERSION=${WEBIFC_VERSION:-$(jq -r '.webifc.version' /versions.json)} \
  && wget -q https://github.com/ThatOpen/engine_web-ifc/archive/refs/tags/$WEBIFC_VERSION.tar.gz -O /webifc-src.tar.gz

RUN mkdir -p /webifc-src && tar -xzf /webifc-src.tar.gz -C /webifc-src --strip-components 1 && rm -rf /webifc-src.tar.gz

COPY webifc-emscripten-install.patch /
RUN patch -p1 -d /webifc-src < /webifc-emscripten-install.patch

RUN cmake -S /webifc-src/src/cpp -B /webifc-build \
  -DBUILD_SHARED_LIBS=OFF \
  -DCMAKE_BUILD_TYPE=Release \
  -DCMAKE_INSTALL_PREFIX:PATH=/depends

RUN cmake --build /webifc-build --target install && rm -rf /webifc-src /webifc-build

######################################
# VTK
######################################
FROM base AS vtk

COPY --from=openvdb /depends /depends

ARG CMAKE_BUILD_PARALLEL_LEVEL=8
ARG VTK_VERSION
RUN VTK_VERSION=${VTK_VERSION:-$(jq -r '.vtk_commit_sha' /versions.json)} \
  && wget -q https://gitlab.kitware.com/vtk/vtk/-/archive/$VTK_VERSION/vtk-$VTK_VERSION.tar.gz -O /vtk-src.tar.gz

RUN mkdir -p /vtk-src && tar -xzf /vtk-src.tar.gz -C /vtk-src --strip-components 1 && rm -rf /vtk-src.tar.gz

RUN cmake -S /vtk-src -B /vtk-build \
  -DBUILD_SHARED_LIBS=OFF \
  -DCMAKE_BUILD_TYPE=Release \
  -DCMAKE_INSTALL_PREFIX:PATH=/depends \
  -DCMAKE_MODULE_PATH=/depends/lib/cmake/OpenVDB/ \
  -DCMAKE_FIND_ROOT_PATH:PATH=/depends \
  -DVTK_BUILD_TESTING=OFF \
  -DVTK_ENABLE_LOGGING=OFF \
  -DVTK_ENABLE_REMOTE_MODULES=OFF \
  -DVTK_ENABLE_WRAPPING=OFF \
  -DVTK_LEGACY_REMOVE=ON \
  -DVTK_GROUP_ENABLE_Imaging=DONT_WANT \
  -DVTK_GROUP_ENABLE_MPI=DONT_WANT \
  -DVTK_GROUP_ENABLE_Qt=DONT_WANT \
  -DVTK_GROUP_ENABLE_Rendering=DONT_WANT \
  -DVTK_GROUP_ENABLE_StandAlone=DONT_WANT \
  -DVTK_GROUP_ENABLE_Views=DONT_WANT \
  -DVTK_GROUP_ENABLE_Web=DONT_WANT \
  -DVTK_MODULE_ENABLE_VTK_CommonCore=YES \
  -DVTK_MODULE_ENABLE_VTK_CommonDataModel=YES \
  -DVTK_MODULE_ENABLE_VTK_CommonExecutionModel=YES \
  -DVTK_MODULE_ENABLE_VTK_CommonSystem=YES \
  -DVTK_MODULE_ENABLE_VTK_FiltersGeneral=YES \
  -DVTK_MODULE_ENABLE_VTK_FiltersGeometry=YES \
  -DVTK_MODULE_ENABLE_VTK_IOCityGML=YES \
  -DVTK_MODULE_ENABLE_VTK_IOExodus=YES \
  -DVTK_MODULE_ENABLE_VTK_IOHDF=YES \
  -DVTK_MODULE_ENABLE_VTK_IOImage=YES \
  -DVTK_MODULE_ENABLE_VTK_IOImport=YES \
  -DVTK_MODULE_ENABLE_VTK_IONetCDF=YES \
  -DVTK_MODULE_ENABLE_VTK_IOOpenVDB=YES \
  -DVTK_MODULE_ENABLE_VTK_IOPLY=YES \
  -DVTK_MODULE_ENABLE_VTK_IOParallel=YES \
  -DVTK_MODULE_ENABLE_VTK_IOXML=YES \
  -DVTK_MODULE_ENABLE_VTK_ImagingCore=YES \
  -DVTK_MODULE_ENABLE_VTK_ImagingHybrid=YES \
  -DVTK_MODULE_ENABLE_VTK_InteractionStyle=YES \
  -DVTK_MODULE_ENABLE_VTK_InteractionWidgets=YES \
  -DVTK_MODULE_ENABLE_VTK_RenderingAnnotation=YES \
  -DVTK_MODULE_ENABLE_VTK_RenderingCore=YES \
  -DVTK_MODULE_ENABLE_VTK_RenderingGridAxes=YES \
  -DVTK_MODULE_ENABLE_VTK_RenderingOpenGL2=YES \
  -DVTK_MODULE_ENABLE_VTK_RenderingVolumeOpenGL2=YES \
  -DVTK_MODULE_ENABLE_VTK_TestingCore=YES \
  -DVTK_MODULE_USE_EXTERNAL_VTK_lz4:BOOL=YES \
  -DVTK_MODULE_USE_EXTERNAL_VTK_zlib:BOOL=YES \
  -DVTK_SMP_IMPLEMENTATION_TYPE=Sequential \
  -DVTK_VERSIONED_INSTALL=OFF

RUN cmake --build /vtk-build --target install && rm -rf /vtk-src /vtk-build

######################################
# Copy artifacts from previous builds
######################################
FROM base AS final

COPY --from=assimp /depends /depends
COPY --from=draco /depends /depends
COPY --from=occt /depends /depends
COPY --from=vtk /depends /depends
COPY --from=webp /depends /depends
COPY --from=webifc /depends /depends

ADD run.sh /run.sh
RUN chmod a+x /run.sh

ENTRYPOINT ["/run.sh"]
