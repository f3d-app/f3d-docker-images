FROM quay.io/pypa/manylinux_2_28_x86_64 

# Install dockerfile dependency
RUN yum -y update && yum install -y \
  xorg-x11-server-Xvfb \
  mesa-dri-drivers \
  git-lfs \
  mesa-libEGL-devel \
  mesa-libOSMesa-devel

# Downgrade cmake for superbuild compat
RUN pipx install cmake==3.31.6 --force
