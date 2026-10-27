# shellcheck shell=bash
# Tool lists of the LLVM installation, shared by scripts/main and
# scripts/test-toolchain.
#
# The build sets LLVM_INSTALL_TOOLCHAIN_ONLY, which installs only the tools
# named in LLVM_TOOLCHAIN_TOOLS. Setting that list replaces the default of
# llvm/cmake/modules/AddLLVM.cmake, so it repeats the default list.
#
# A tool that LLVM creates as a symlink, such as llvm-readelf to llvm-readobj,
# is installed only when both the link name and its target are in the list.

# The default LLVM_TOOLCHAIN_TOOLS of LLVM 23.1.4. The build forces
# libxml2 on, so llvm-mt is always built. The unprefixed names are binutils
# symlinks, which LLVM creates only with LLVM_INSTALL_BINUTILS_SYMLINKS.
# shellcheck disable=SC2034 # used by the scripts that source this file
DEFAULT_TOOLCHAIN_TOOLS=(
  llvm-ar
  llvm-cov
  llvm-cxxfilt
  llvm-dlltool
  llvm-dwp
  llvm-ranlib
  llvm-lib
  llvm-mca
  llvm-ml
  llvm-ml64
  llvm-nm
  llvm-objcopy
  llvm-objdump
  llvm-pdbutil
  llvm-rc
  llvm-readobj
  llvm-size
  llvm-strings
  llvm-strip
  llvm-profdata
  llvm-profgen
  llvm-symbolizer
  addr2line
  ar
  c++filt
  ranlib
  nm
  objcopy
  objdump
  readelf
  size
  strings
  strip
  llvm-mt
)

# The LLVM tools that the osxcross llvm flavor runs in place of cctools and
# ld64 (osxcross wrapper/progs.h and build.sh). ld64.lld is an LLD symlink,
# which LLD installs with every build.
# shellcheck disable=SC2034 # used by the scripts that source this file
DARWIN_TOOLS=(
  ld64.lld
  dsymutil
  llvm-ar
  llvm-bcanalyzer
  llvm-bitcode-strip
  llvm-config
  llvm-cov
  llvm-cxxfilt
  llvm-dis
  llvm-dwarfdump
  llvm-install-name-tool
  llvm-libtool-darwin
  llvm-link
  llvm-lipo
  llvm-lto
  llvm-lto2
  llvm-nm
  llvm-objcopy
  llvm-objdump
  llvm-otool
  llvm-profdata
  llvm-ranlib
  llvm-readelf
  llvm-readobj
  llvm-readtapi
  llvm-size
  llvm-strings
  llvm-strip
  llvm-symbolizer
)

# The LLVM tools that the target-prefixed MinGW tools of llvm-mingw
# (install-wrappers.sh) link to, such as x86_64-w64-mingw32-windres to
# llvm-windres. llvm-addr2line and llvm-windres are symlinks to
# llvm-symbolizer and llvm-rc.
# shellcheck disable=SC2034 # used by the scripts that source this file
MINGW_TOOLS=(
  llvm-addr2line
  llvm-ar
  llvm-dlltool
  llvm-nm
  llvm-objcopy
  llvm-objdump
  llvm-ranlib
  llvm-rc
  llvm-readelf
  llvm-readobj
  llvm-size
  llvm-strings
  llvm-strip
  llvm-symbolizer
  llvm-windres
)

# Print the LLVM_TOOLCHAIN_TOOLS value of the build: the default list, the
# Darwin tools, and the MinGW tools, separated by semicolons.
function toolchain_tools() {
  printf '%s\n' "${DEFAULT_TOOLCHAIN_TOOLS[@]}" "${DARWIN_TOOLS[@]}" "${MINGW_TOOLS[@]}" |
    LC_ALL=C sort -u | paste -sd ';' -
}
