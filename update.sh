#!/bin/bash -e

# Copy binaries
for b in bin/*; do
  file=`basename $b`
  # Don't copy symlinks like clang++
  if test -h $b; then
    echo Skipping $file
  else
    echo Copying $file
    cp -a `find ${ANDROID_HOST_OUT}/bin -name $file` $b
    strip $b
  fi
done

# Copy libraries
echo Copying libc++.so
cp -a ${ANDROID_HOST_OUT}/lib/libc++.so lib/
cp -a ${ANDROID_HOST_OUT}/lib64/libc++.so lib64/

# Copy header files
rm -rf lib/clang/*/include/*
for i in `find ${ANDROID_BUILD_TOP}/external/clang/lib/Headers -mindepth 1 ! -name \*.mk -a ! -name Makefile -a ! -name CMakeLists.txt`; do
  echo Copying `basename $i`
  cp -a $i lib/clang/*/include/
done

echo Copying sanitizer headers
cp -a ${ANDROID_BUILD_TOP}/external/compiler-rt/include/sanitizer lib/clang/*/include/

# Copy over stdatomic.h from bionic
echo Copying stdatomic.h
cp -a ${ANDROID_BUILD_TOP}/bionic/libc/include/stdatomic.h lib/clang/*/include/

echo Copying arm_neon.h
cp -a `find ${ANDROID_PRODUCT_OUT} -name arm_neon.h` lib/clang/*/include

echo Copying ASan libraries
LIBS=$(echo lib/clang/*)/lib/linux
cp -a ${ANDROID_HOST_OUT}/obj/STATIC_LIBRARIES/libasan_intermediates/libasan.a \
  ${LIBS}/libclang_rt.asan-x86_64.a
cp -a ${ANDROID_HOST_OUT}/obj/STATIC_LIBRARIES/libasan_cxx_intermediates/libasan_cxx64.a \
  ${LIBS}/libclang_rt.asan_cxx-x86_64.a
cp -a ${ANDROID_HOST_OUT}/obj32/STATIC_LIBRARIES/libasan_intermediates/libasan.a \
  ${LIBS}/libclang_rt.asan-i686.a
cp -a ${ANDROID_HOST_OUT}/obj32/STATIC_LIBRARIES/libasan_cxx_intermediates/libasan_cxx32.a \
  ${LIBS}/libclang_rt.asan_cxx-i686.a
