# See https://cmake.org/cmake/help/latest/manual/cmake-toolchains.7.html#cross-compiling-for-android-with-the-ndk
set(CMAKE_SYSTEM_NAME Android)
set(CMAKE_SYSTEM_VERSION $ENV{ANDROID_API})

set(CMAKE_ANDROID_ARCH_ABI $ENV{ANDROID_ARCH})
set(CMAKE_ANDROID_NDK /ndk)

set(CMAKE_FIND_ROOT_PATH /depends)
