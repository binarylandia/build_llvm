# Prebuilt LLVM/Clang toolchain for x86_64 Linux

## [Releases](https://github.com/binarylandia/build_llvm/releases)

Builds a portable LLVM installation on manylinux2014 (glibc 2.17) with Clang, LLD, LLDB, Flang, and OpenMP. Statically linked for deployment without runtime dependencies.

Targets x86_64 Linux hosts. Supports code generation for x86_64, AArch64, and ARM.

## Components

- Clang and clang-tools-extra
- LLD linker
- LLDB debugger
- Flang Fortran compiler
- OpenMP runtime (libomp)
- compiler-rt, libc++, libc++abi, libunwind

## Features

- Statically linked against libgcc and libstdc++
- FFI, RTTI, and threading enabled
- zlib and zstd compression support
- Perf profiling support

## Use Cases

- CI/CD pipelines requiring LLVM tools
- Cross-compilation with Clang
- Static analysis and code formatting
- Building with libc++ instead of libstdc++

## Keywords

prebuilt llvm, prebuilt clang, llvm binary, clang download, linux compiler, portable llvm, static clang, manylinux llvm, lld linker, lldb debugger, flang fortran, libc++
