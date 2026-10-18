# Prebuilt LLVM/Clang toolchain for x86_64 Linux

## [Releases](https://github.com/binarylandia/build_llvm/releases)

Builds a portable LLVM installation on manylinux2014 (glibc 2.17) with Clang, LLD, LLDB, Flang, and OpenMP. GCC and C++ runtimes are linked statically into the tools. Host system libraries, including glibc, can remain dynamic dependencies.

Targets x86_64 Linux hosts. Supports code generation for x86_64, AArch64, ARM, and WebAssembly (wasm32 and wasm64). WASI and Emscripten sysroots are supplied separately. MinGW runtimes for x86_64 and AArch64 Windows come in a separate archive (see [MinGW runtimes](#mingw-runtimes)).

## Build

Run one version per invocation:

```bash
./build './scripts/main 22.1.8'
./build './scripts/main 23.1.1'
```

Source checksums are pinned in `scripts/sources.sha256`. Each version has a separate build and installation directory. Builds run native C/C++, libc++, Fortran, and OpenMP checks, compile and link wasm32 and wasm64 modules, check the Darwin tools, and check the MinGW runtimes before packaging. Archives, `SHA256SUMS`, and one metadata file are written to `.out/llvm-<version>-<build time>/`.

Compile parallelism defaults to 6 jobs, with one link job. For example:

```bash
./build 'JOBS=8 LINK_JOBS=1 ./scripts/main 22.1.8'
```

LLDB is built without Python, curses, and libedit integration to avoid their host runtime dependencies.

## Release

```bash
# Check, then publish .out/llvm-<version>-<build time>/ as release llvm-<version>-<build time>
./scripts/release --dry-run <build time>
./scripts/release <build time>
```

- The base image is pinned by digest in `build`, and the LLVM source by checksum
- Archives list their files in sorted order with one owner and the commit time, so the same files give the same archive
- `scripts/release` publishes only a build of a clean, pushed commit, and never changes a published release
- Each release has `SHA256SUMS` and `manifest.json`, which records the LLVM version, source tarball and checksum, projects, runtimes, targets, Darwin tools, MinGW triples, mingw-w64 version and C runtime, llvm-mingw commit, base image, and build commit

For native static C++ programs with the LLVM runtimes, use:

```bash
clang++ -fuse-ld=lld -stdlib=libc++ --rtlib=compiler-rt --unwindlib=libunwind -static -pthread program.cpp -ldl
```

OpenMP programs link libomp statically and use the system glibc.

## MinGW runtimes

`llvm-mingw-<version>-<build time>.tar.*` holds MinGW-w64 runtimes for `x86_64-w64-mingw32` and `aarch64-w64-mingw32`, built with the clang, lld, and LLVM tools of the same release. Unpack it into the prefix of the LLVM archive:

```bash
tar -C /opt/llvm -xf llvm-22.1.8-<build time>.tar.xz
tar -C /opt/llvm -xf llvm-mingw-22.1.8-<build time>.tar.xz
/opt/llvm/bin/x86_64-w64-mingw32-clang++ program.cpp -o program.exe
```

- **Contents**: mingw-w64 headers and CRT, winpthreads, compiler-rt builtins, libunwind, libc++abi, and libc++, built with the scripts of [llvm-mingw](https://github.com/mstorsjo/llvm-mingw) at a pinned commit, in its layout: a sysroot `<prefix>/<triple>/` per target, the builtins in `lib/clang/<major>/lib/windows/`, and target-prefixed tools in `bin/`
- **C runtime**: the UCRT, which is part of Windows 10 and later
- **Static runtimes**: every runtime is a static library, so programs import only Windows system DLLs such as `KERNEL32.dll` and `api-ms-win-crt-*.dll`
- **Compiler setup**: `<arch>-w64-windows-gnu.cfg` and its `<arch>-pc-windows-gnu.cfg` link in `bin/` select lld, compiler-rt, libunwind, and libc++. Clang loads them for `<arch>-w64-mingw32-clang` and for `clang --target=<arch>-pc-windows-gnu`
- **Rust**: the `x86_64-pc-windows-gnullvm` and `aarch64-pc-windows-gnullvm` targets use `<arch>-w64-mingw32-clang` as the linker and C compiler
- **Separate archive**: consumers that do not target Windows use the LLVM archive alone. The MinGW archive does not combine with a GCC MinGW toolchain in the same prefix, because both use `<prefix>/<triple>/` and the `<triple>-gcc` names

## Components

- Clang and clang-tools-extra
- LLD linker, including `ld64.lld` for Mach-O
- Darwin tools that the osxcross `llvm` flavor runs in place of cctools: `dsymutil`, `llvm-lipo`, `llvm-otool`, `llvm-install-name-tool`, `llvm-libtool-darwin`, `llvm-readtapi`, `llvm-bitcode-strip`, `llvm-dwarfdump`, and others
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
