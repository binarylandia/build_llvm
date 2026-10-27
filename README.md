# Prebuilt LLVM/Clang toolchain for x86_64 Linux

## [Releases](https://github.com/binarylandia/build_llvm/releases)

Builds a portable LLVM installation with Clang, LLD, LLDB, Flang, and OpenMP that runs on x86_64 Linux with glibc 2.17 or later. The tools link libc++, libc++abi, libunwind, the compiler-rt builtins, zlib, zstd, libxml2, and libffi statically; glibc remains a dynamic dependency.

Targets x86_64 Linux hosts. Supports code generation for x86_64, AArch64, ARM, and WebAssembly (wasm32 and wasm64). WASI and Emscripten sysroots are supplied separately. MinGW runtimes for x86_64 and AArch64 Windows come in a separate archive (see [MinGW runtimes](#mingw-runtimes)).

## Build

Run one version per invocation:

```bash
./build './scripts/main 23.1.4'
```

LLVM builds in three stages, all on the glibc 2.17 sysroot of the `x86_64-unknown-linux-gnu` GCC 16 toolchain of [build_crosstool-ng](https://github.com/binarylandia/build_crosstool-ng), which clang reads from a configuration file next to it in each build tree:

1. The GCC of that toolchain builds clang, lld, and the LLVM runtimes (static libc++, libc++abi, libunwind, compiler-rt)
2. The clang of stage 1 builds a clang and an lld with IR instrumentation, which record a profile while they compile and link a part of LLVM and Clang
3. The clang of stage 1 builds the installation with that profile and ThinLTO, and links the tools against the runtimes of stage 1. Flang compiles without the profile, which holds no flang samples and makes clang spend hours on some flang sources (`patches/002-flang-without-pgo-profile.patch`)

The LLVM major and minor version follow the LLVM that the Rust release of the consumers bundles (`rustc -vV`), with the newest patch release of that series: Rust 1.99.1 bundles LLVM 23.1.1, and this build is LLVM 23.1.4. Consumers that mix Rust and C code, or use the LLVM tools on the profiles and object files of rustc, then work with one LLVM release series. Source checksums are pinned in `scripts/sources.sha256`. Each version has a separate build and installation directory. Builds run native C/C++, libc++, Fortran, and OpenMP checks, compile and link wasm32 and wasm64 modules, check the Darwin tools, and check the MinGW runtimes before packaging. Archives, `SHA256SUMS`, and one metadata file are written to `.out/llvm-<version>-<build time>/`.

Compile parallelism defaults to 6 jobs, with one link job. For example:

```bash
./build 'JOBS=8 LINK_JOBS=1 ./scripts/main 23.1.4'
```

LLDB is built without Python, curses, and libedit integration to avoid their host runtime dependencies.

## Release

```bash
# Check, then publish .out/llvm-<version>-<build time>/ as release llvm-<version>-<build time>
./scripts/release --dry-run <build time>
./scripts/release <build time>
```

- The base image (Debian 13) is pinned by digest in `build`, and the LLVM source by checksum
- The image trusts neither emSign ECC Root CA - G3 nor AAA Certificate Services, the roots above the eMudhra intermediate CAs whose private keys became public in October 2026 (`dev/docker/files/distrust-compromised-roots`)
- The image downloads the host GCC toolchain and the sources of zlib, zstd, libxml2, and libffi through `dev/docker/files/fetch`, which fails unless a download matches its checksum in `dev/docker/files/checksums`
- Archives list their files in sorted order with one owner and the commit time, so the same files give the same archive
- `scripts/release` publishes only a build of a clean, pushed commit, and never changes a published release
- Each release has `SHA256SUMS` and `manifest.json`, which records the LLVM version, source tarball and checksum, projects, runtimes, targets, Darwin tools, MinGW triples, mingw-w64 version and C runtime, llvm-mingw commit, the stages and the host GCC toolchain, base image, and build commit

For native static C++ programs with the LLVM runtimes, use:

```bash
clang++ -fuse-ld=lld -stdlib=libc++ --rtlib=compiler-rt --unwindlib=libunwind -static -pthread program.cpp -ldl
```

OpenMP programs link libomp statically and use the system glibc.

## MinGW runtimes

`llvm-mingw-<version>-<build time>.tar.*` holds MinGW-w64 runtimes for `x86_64-w64-mingw32` and `aarch64-w64-mingw32`, built with the clang, lld, and LLVM tools of the same release. Unpack it into the prefix of the LLVM archive:

```bash
tar -C /opt/llvm -xf llvm-23.1.4-<build time>.tar.xz
tar -C /opt/llvm -xf llvm-mingw-23.1.4-<build time>.tar.xz
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

- Optimized with a profile of the compiler itself (PGO) and ThinLTO
- Statically linked against libc++, libc++abi, libunwind, and the compiler-rt builtins
- FFI, RTTI, and threading enabled
- zlib and zstd compression support
- Perf profiling support

## Use Cases

- CI/CD pipelines requiring LLVM tools
- Cross-compilation with Clang
- Static analysis and code formatting
- Building with libc++ instead of libstdc++

## Keywords

prebuilt llvm, prebuilt clang, llvm binary, clang download, linux compiler, portable llvm, static clang, glibc 2.17 llvm, pgo clang, lld linker, lldb debugger, flang fortran, libc++
