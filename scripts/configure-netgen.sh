#!/usr/bin/env bash
# Netgen: find_package(OpenCascade …) needs installed OCCT (lib/cmake/opencascade-*). Hint: OpenCascade_DIR.
set -euo pipefail
mode="${1:?usage: configure-netgen.sh debug|release}"
root="${PIXI_PROJECT_ROOT:-$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)}"

if [ "$mode" = debug ]; then
  build_type=Debug
  stack_prefix="$root/install/debug"
  build_dir="build/debug/netgen"
elif [ "$mode" = release ]; then
  build_type=Release
  stack_prefix="$root/install/release"
  build_dir="build/release/netgen"
else
  echo >&2 "configure-netgen.sh: need debug or release"
  exit 1
fi

unset OpenCascade_DIR OpenCASCADE_DIR
opencascade_dir=""
for d in "$stack_prefix/lib/cmake"/opencascade*; do
  if [ -f "$d/OpenCASCADEConfig.cmake" ]; then
    opencascade_dir=$d
    break
  fi
done

if [ -z "$opencascade_dir" ]; then
  echo >&2 "configure-netgen: No installed OpenCASCADE under $stack_prefix/lib/cmake/opencascade*"
  echo >&2 "Build and install OCCT first: pixi run -e ${mode} install-${mode}-occt"
  exit 1
fi

cmake \
  -S "$root/third_party/netgen" \
  -B "$root/$build_dir" \
  -G Ninja \
  "-DCMAKE_BUILD_TYPE=$build_type" \
  -DUSE_SUPERBUILD=OFF \
  "-DCMAKE_INSTALL_PREFIX=$CONDA_PREFIX" \
  "-DCMAKE_PREFIX_PATH=${stack_prefix}:${CONDA_PREFIX}" \
  "-DOpenCascade_DIR=$opencascade_dir" \
  "-DPython3_EXECUTABLE=$CONDA_PREFIX/bin/python" \
  "-DPython3_ROOT_DIR=$CONDA_PREFIX" \
  -DPython3_FIND_STRATEGY=LOCATION
