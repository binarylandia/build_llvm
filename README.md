# Prebuilt LLVM/Clang toolchain for x86_64 Linux

## [Releases](https://github.com/binarylandia/build_llvm/releases)

Builds a portable LLVM installation on manylinux2014 (glibc 2.17) with Clang, LLD, LLDB, Flang, and OpenMP. GCC and C++ runtimes are linked statically into the tools. Host system libraries, including glibc, can remain dynamic dependencies.

Targets x86_64 Linux hosts. Supports code generation for x86_64, AArch64, ARM, and WebAssembly (wasm32 and wasm64). WASI and Emscripten sysroots are supplied separately.

## Build

Run one version per invocation:

```bash
./build './scripts/main 22.1.8'
./build './scripts/main 23.1.1'
```

Source checksums are pinned in `scripts/sources.sha256`. Each version has a separate build and installation directory. Builds run native C/C++, libc++, Fortran, and OpenMP checks, then compile and link wasm32 and wasm64 modules before packaging. Artifacts and `SHA256SUMS` are written to `.out/llvm-<version>-<timestamp>/`.

Compile parallelism defaults to 6 jobs, with one link job. For example:

```bash
./build 'JOBS=8 LINK_JOBS=1 ./scripts/main 22.1.8'
```

LLDB is built without Python, curses, and libedit integration to avoid their host runtime dependencies.

For native static C++ programs with the LLVM runtimes, use:

```bash
clang++ -fuse-ld=lld -stdlib=libc++ --rtlib=compiler-rt --unwindlib=libunwind -static -pthread program.cpp -ldl
```

The static OpenMP runtime is tested with dynamic glibc. Fully static OpenMP executables are not supported by this glibc-based build.

## Components

- Clang and clang-tools-extra
- LLD linker
- LLDB debugger
- Flang Fortran compiler
- Static OpenMP runtime (libomp)
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
