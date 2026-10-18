# shellcheck shell=bash
# Versions and targets of the MinGW-w64 runtimes, shared by scripts/main,
# scripts/build-mingw, and scripts/test-mingw.
#
# The runtimes are built with the scripts of llvm-mingw on top of the installed
# clang, lld, and LLVM tools, so the compiler, the linker, compiler-rt, and the
# C++ runtime all come from one LLVM version. They install in the layout of
# llvm-mingw: a sysroot <prefix>/<triple>/ per target, which clang finds next to
# its bin/ folder, the compiler-rt builtins in the clang resource folder
# (lib/clang/<major>/lib/windows/), and target-prefixed tools in bin/
# (x86_64-w64-mingw32-clang and others) with the <arch>-w64-windows-gnu.cfg
# config files that select lld, compiler-rt, libunwind, and libc++.
#
# Every runtime is a static library, so programs import only Windows system
# DLLs. The C runtime is the UCRT, which is part of Windows 10 and later.

# shellcheck disable=SC2034 # used by the scripts that source this file
MINGW_ARCHS=(x86_64 aarch64)

MINGW_W64_VERSION="v14.0.0"
# shellcheck disable=SC2034 # used by the scripts that source this file
MINGW_W64_SOURCE="mingw-w64-${MINGW_W64_VERSION}.tar.bz2"
# shellcheck disable=SC2034 # used by the scripts that source this file
MINGW_W64_URL="https://downloads.sourceforge.net/project/mingw-w64/mingw-w64/mingw-w64-release/${MINGW_W64_SOURCE}"
MINGW_CRT="ucrt"
# Windows 7, the default of mingw-w64 and llvm-mingw.
MINGW_WIN32_WINNT="0x601"

# llvm-mingw release 20260616, the last release built with LLVM 22 (22.1.8).
# shellcheck disable=SC2034 # used by the scripts that source this file
LLVM_MINGW_TAG="20260616"
LLVM_MINGW_COMMIT="170b7e1ec4ad1d9264e6ba320cd4d02f96299c60"
# shellcheck disable=SC2034 # used by the scripts that source this file
LLVM_MINGW_SOURCE="llvm-mingw-${LLVM_MINGW_COMMIT}.tar.gz"
# shellcheck disable=SC2034 # used by the scripts that source this file
LLVM_MINGW_URL="https://github.com/mstorsjo/llvm-mingw/archive/${LLVM_MINGW_COMMIT}.tar.gz"

# shellcheck disable=SC2034 # used by the scripts that source this file
MINGW_RUNTIMES=(mingw-w64-headers mingw-w64-crt compiler-rt-builtins libunwind libcxxabi libcxx winpthreads)

# Print the MinGW target triples, one per line.
function mingw_triples() {
  local arch
  for arch in "${MINGW_ARCHS[@]}"; do
    printf '%s-w64-mingw32\n' "${arch}"
  done
}
