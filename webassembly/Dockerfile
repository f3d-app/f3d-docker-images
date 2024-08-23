FROM dockcross/web-wasm:20240529-0dade71 AS base

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
  -DVTK_MODULE_ENABLE_VTK_IOImage=YES \
  -DVTK_MODULE_ENABLE_VTK_IOImport=YES \
  -DVTK_MODULE_ENABLE_VTK_IOPLY=YES \
  -DVTK_MODULE_ENABLE_VTK_IOParallel=YES \
  -DVTK_MODULE_ENABLE_VTK_IOXML=YES \
  -DVTK_MODULE_ENABLE_VTK_ImagingCore=YES \
  -DVTK_MODULE_ENABLE_VTK_ImagingHybrid=YES \
  -DVTK_MODULE_ENABLE_VTK_InteractionStyle=YES \
  -DVTK_MODULE_ENABLE_VTK_InteractionWidgets=YES \
  -DVTK_MODULE_ENABLE_VTK_RenderingAnnotation=YES \
  -DVTK_MODULE_ENABLE_VTK_RenderingCore=YES \
  -DVTK_MODULE_ENABLE_VTK_RenderingOpenGL2=YES \
  -DVTK_MODULE_ENABLE_VTK_RenderingVolumeOpenGL2=YES \
  -DVTK_MODULE_ENABLE_VTK_TestingCore=YES \
  -DVTK_SMP_IMPLEMENTATION_TYPE=Sequential \
  -DVTK_VERSIONED_INSTALL=OFF

RUN cmake --build /vtk-build --target install && rm -rf /vtk-src /vtk-build

######################################
# Copy artifacts from previous builds
######################################
FROM base

COPY --from=assimp /depends /depends
COPY --from=vtk /depends /depends
