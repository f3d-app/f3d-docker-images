FROM ubuntu:24.04

ADD https://gitlab.kitware.com/vtk/vtk/-/archive/v9.5.0/vtk-v9.5.0.tar.gz /vtk-src.tar.gz

RUN mkdir -p /vtk-src && tar -xzf /vtk-src.tar.gz -C /vtk-src --strip-components 1 && rm -rf /vtk-src.tar.gz
