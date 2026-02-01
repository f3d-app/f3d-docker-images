FROM debian:stable-slim AS base

# Install generic build dependency
RUN apt update && apt install -y \
      build-essential \
      cmake \
      ninja-build \
      python3 \
      nodejs \
      node-typescript

# Install CI tools
RUN apt update && apt install -y \
      git \
      git-lfs \
      chromium \
      xvfb \
      dbus-x11

# Install Emscripten SDK
ADD https://github.com/emscripten-core/emsdk/archive/refs/tags/4.0.10.tar.gz /emsdk.tar.gz

RUN mkdir -p /emsdk && tar -xzf /emsdk.tar.gz -C /emsdk --strip-components 1 && rm -rf /emsdk.tar.gz

RUN /emsdk/emsdk install latest

# Configure build environment variables
ENV CMAKE_GENERATOR=Ninja
ENV CMAKE_TOOLCHAIN_FILE=/emsdk/upstream/emscripten/cmake/Modules/Platform/Emscripten.cmake
ENV PATH=/emsdk/upstream/bin:/emsdk/upstream/emscripten:$PATH
ENV CXXFLAGS=-fwasm-exceptions

######################################
# Assimp
######################################
FROM base AS assimp

ARG CMAKE_BUILD_PARALLEL_LEVEL=8
ARG ASSIMP_VERSION
RUN [ -n "$ASSIMP_VERSION" ]

ADD https://github.com/assimp/assimp/archive/refs/tags/$ASSIMP_VERSION.tar.gz /assimp-src.tar.gz

RUN mkdir -p /assimp-src && tar -xzf /assimp-src.tar.gz -C /assimp-src --strip-components 1 && rm -rf /assimp-src.tar.gz

RUN cmake -S /assimp-src -B /assimp-build \
  -DBUILD_SHARED_LIBS=OFF \
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
  -DASSIMP_BUILD_ZLIB=ON \
  -DASSIMP_NO_EXPORT=ON \
  -DASSIMP_WARNINGS_AS_ERRORS=OFF

RUN cmake --build /assimp-build --target install && rm -rf /assimp-src /assimp-build

######################################
# OCCT
######################################
FROM base AS occt

ARG CMAKE_BUILD_PARALLEL_LEVEL=8
ARG OCCT_VERSION
RUN [ -n "$OCCT_VERSION" ]

ADD https://github.com/Open-Cascade-SAS/OCCT/archive/refs/tags/$OCCT_VERSION.tar.gz /occt-src.tar.gz

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
RUN [ -n "$DRACO_VERSION" ]

ADD https://github.com/google/draco/archive/refs/tags/$DRACO_VERSION.tar.gz /draco-src.tar.gz

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
RUN [ -n "$WEBP_VERSION" ]

ADD https://github.com/webmproject/libwebp/archive/refs/tags/$WEBP_VERSION.tar.gz /webp-src.tar.gz

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
RUN [ -n "$WEBIFC_VERSION" ]

ADD https://github.com/ThatOpen/engine_web-ifc/archive/refs/tags/$WEBIFC_VERSION.tar.gz /webifc-src.tar.gz

RUN mkdir -p /webifc-src && tar -xzf /webifc-src.tar.gz -C /webifc-src --strip-components 1 && rm -rf /webifc-src.tar.gz

RUN cmake -S /webifc-src/src/cpp -B /webifc-build \
  -DBUILD_SHARED_LIBS=OFF \
  -DCMAKE_BUILD_TYPE=Release \
  -DCMAKE_INSTALL_PREFIX:PATH=/depends

RUN cmake --build /webifc-build --target install && rm -rf /webifc-src /webifc-build

######################################
# VTK
######################################
FROM base AS vtk

ARG CMAKE_BUILD_PARALLEL_LEVEL=8
ARG VTK_VERSION
RUN [ -n "$VTK_VERSION" ]

ADD https://gitlab.kitware.com/vtk/vtk/-/archive/$VTK_VERSION/vtk-$VTK_VERSION.tar.gz /vtk-src.tar.gz

RUN mkdir -p /vtk-src && tar -xzf /vtk-src.tar.gz -C /vtk-src --strip-components 1 && rm -rf /vtk-src.tar.gz

RUN cmake -S /vtk-src -B /vtk-build \
  -DBUILD_SHARED_LIBS=OFF \
  -DCMAKE_BUILD_TYPE=Release \
  -DCMAKE_INSTALL_PREFIX:PATH=/depends \
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
