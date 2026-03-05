# This file sets up a CMakeCache for a simple distribution bootstrap build.
#
# This is based on an example cache file provided by Clang and originally came
# from "llvm/clang/cmake/caches/DistributionExample.cmake".
#
# The original example file did not have a copyright or license notice, but
# Clang is covered under a modified Apache 2.0 license. Presumably, that
# includes the example code and so this will follow suit. A copy of the
# license is provided in LICENSE.txt.

# Enable LLVM projects and runtimes
# The proper variable to check is 'MSVC', but that is not yet checked when this file is parsed.
# The best we can do is 'WIN32' for now. This check is here because libunwind and libcxxabi
# are not supported with MSVC.
set(LLVM_ENABLE_PROJECTS "clang;clang-tools-extra;lld;lldb;polly" CACHE STRING "")
if(WIN32)
  set(LLVM_ENABLE_RUNTIMES "compiler-rt;libcxx" CACHE STRING "")
else()
  set(LLVM_ENABLE_RUNTIMES "compiler-rt;libunwind;libcxx;libcxxabi" CACHE STRING "")
endif()

# Only build the native target in stage1 since it is a throwaway build.
set(LLVM_TARGETS_TO_BUILD Native CACHE STRING "")

# Optimize the stage1 compiler, but don't LTO it because that wastes time.
set(CMAKE_BUILD_TYPE Release CACHE STRING "")

# Setting up the stage2 LTO option needs to be done on the stage1 build so that
# the proper LTO library dependencies can be connected.
set(BOOTSTRAP_LLVM_ENABLE_LTO ON CACHE BOOL "")

if (NOT APPLE)
  # Since LLVM_ENABLE_LTO is ON we need a LTO capable linker
  set(BOOTSTRAP_LLVM_ENABLE_LLD ON CACHE BOOL "")
endif()

# Build minimum Compiler-RT for stage1
set(COMPILER_RT_DEFAULT_TARGET_ONLY ON CACHE BOOL "")
set(COMPILER_RT_BUILD_SANITIZERS OFF CACHE BOOL "")
set(COMPILER_RT_BUILD_XRAY OFF CACHE BOOL "")
set(COMPILER_RT_BUILD_LIBFUZZER OFF CACHE BOOL "")
set(COMPILER_RT_BUILD_PROFILE OFF CACHE BOOL "")
set(COMPILER_RT_BUILD_MEMPROF OFF CACHE BOOL "")
set(COMPILER_RT_BUILD_CTX_PROFILE OFF CACHE BOOL "")
set(COMPILER_RT_BUILD_ORC OFF CACHE BOOL "")

# If LLVM_BUILD_DOCS is ON, then we want to add targets to build and install documentation. To see 
# what documentation targets are avaiable, you need to generate a configuration with LLVM_BUILD_DOCS
# enabled. Then go into the build directory ("mchpclang/build/llvm" if you are using this with the
# "buildMchpClang.py" script) and run "cmake --build . --target help | grep install-docs".
if(LLVM_BUILD_DOCS  OR  BOOTSTRAP_LLVM_BUILD_DOCS)
  set(doc_targets
    sphinx
    install-docs-clang-html
    install-docs-clang-man
    install-docs-clang-tools-html
    install-docs-clang-tools-man
    # there is no install-docs-dsymutil-html target
    install-docs-dsymutil-man
    install-docs-lld-html
    # there is no install-docs-lld-man target
    # there is no install-docs-llvm-dwarfdump-html target
    install-docs-llvm-dwarfdump-man
    install-docs-llvm-html
    install-docs-llvm-man
    install-docs-polly-html
    install-docs-polly-man
  )
else()
  set(doc_targets "")
endif()

# This creates "stage2-<target>" entries that redirect to "<target>" entries in the stage2 build
# script. This is mainly for convenience to let you access stage2 stuff from the top-level build
# directory. Presumably, LLVM's CMake stuff sets up dependency stuff since running, for example,
# "stage2-distribution" will build the stage1 compiler first if needed.
#
# The stage2 stuff is put into the build directory at "tools/clang/stage2-bins".
set(CLANG_BOOTSTRAP_TARGETS
  check-all
  check-llvm
  check-clang
  clang
  llvm-config
  test-suite
  test-depends
  llvm-test-depends
  clang-test-depends
  distribution
  install-distribution
  ${doc_targets}
  CACHE STRING ""
)

# Setup the bootstrap build.
set(CLANG_ENABLE_BOOTSTRAP ON CACHE BOOL "")

if(STAGE2_CACHE_FILE)
  set(CLANG_BOOTSTRAP_CMAKE_ARGS
    -C ${STAGE2_CACHE_FILE}
    CACHE STRING "")
else()
  set(CLANG_BOOTSTRAP_CMAKE_ARGS
    -C ${CMAKE_CURRENT_LIST_DIR}/mchpclang-llvm-stage2.cmake
    CACHE STRING "")
endif()
