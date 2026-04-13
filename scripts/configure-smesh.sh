#!/usr/bin/env bash
# SMESH: find_package(OpenCASCADE) braucht installiertes OCCT (lib/cmake/opencascade-*), nicht einen OCCT-Buildtree.
set -euo pipefail
mode="${1:?usage: configure-smesh.sh debug|release}"
root="${PIXI_PROJECT_ROOT:-$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)}"

if [ "$mode" = debug ]; then
  build_type=Debug
  prefix="$root/install/debug"
  build_dir="build/debug/smesh"
elif [ "$mode" = release ]; then
  build_type=Release
  prefix="$root/install/release"
  build_dir="build/release/smesh"
else
  echo >&2 "configure-smesh.sh: need debug or release"
  exit 1
fi

unset OpenCASCADE_DIR
opencascade_dir=""
for d in "$prefix/lib/cmake"/opencascade*; do
  if [ -f "$d/OpenCASCADEConfig.cmake" ]; then
    opencascade_dir=$d
    break
  fi
done

cmake_args=(
  -S "$root/third_party/smesh"
  -B "$root/$build_dir"
  -G Ninja
  "-DCMAKE_BUILD_TYPE=$build_type"
  "-DCMAKE_INSTALL_PREFIX=$prefix"
  "-DCMAKE_PREFIX_PATH=${prefix}:${CONDA_PREFIX}"
)
if [ -z "$opencascade_dir" ]; then
  echo >&2 "configure-smesh: Kein installiertes OpenCASCADE unter $prefix/lib/cmake/opencascade*"
  echo >&2 "Zuerst OCCT bauen und installieren: pixi run -e ${mode} install-${mode}-occt"
  exit 1
fi
cmake_args+=(-DOpenCASCADE_DIR="$opencascade_dir")

cmake "${cmake_args[@]}"
