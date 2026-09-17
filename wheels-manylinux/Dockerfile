FROM quay.io/pypa/manylinux_2_34_x86_64

# Install dockerfile dependency
RUN yum -y update && yum install -y \
  cmake                \
  flex                 \
  git-lfs              \
  mesa-dri-drivers     \
  mesa-libEGL-devel    \
  xorg-x11-server-Xvfb
