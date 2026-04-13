#!/usr/bin/env bash
# Pivy erzeugt sehr große SWIG-Dateien (coinPYTHON_wrap.cxx). Conda setzt oft CXXFLAGS=-O3,
# was cc1plus mit viel RAM füttert → OOM ("Killed signal"). Ohne -O3 bzw. mit -O1/-O2 stabiler.
# Build (pixi.toml): build-debug/release-pivy immer cmake --build … --parallel 1 — unabhängig von set-parallel.
set -euo pipefail
mode="${1:?usage: configure-pivy.sh debug|release}"
root="${PIXI_PROJECT_ROOT:-$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)}"
unset CXXFLAGS CFLAGS || true
if [ "$mode" = debug ]; then
  cmake -S "$root/third_party/pivy" -B "$root/build/debug/pivy" -G Ninja \
    -DCMAKE_BUILD_TYPE=Debug \
    -DCMAKE_INSTALL_PREFIX="$root/install/debug" \
    -DCMAKE_PREFIX_PATH="$root/install/debug:$CONDA_PREFIX" \
    -DPython_EXECUTABLE="$CONDA_PREFIX/bin/python" \
    -DPIVY_USE_QT6=ON \
    -DCMAKE_CXX_FLAGS="-O1 -g"
elif [ "$mode" = release ]; then
  cmake -S "$root/third_party/pivy" -B "$root/build/release/pivy" -G Ninja \
    -DCMAKE_BUILD_TYPE=Release \
    -DCMAKE_INSTALL_PREFIX="$root/install/release" \
    -DCMAKE_PREFIX_PATH="$root/install/release:$CONDA_PREFIX" \
    -DPython_EXECUTABLE="$CONDA_PREFIX/bin/python" \
    -DPIVY_USE_QT6=ON \
    -DCMAKE_CXX_FLAGS="-O2"
else
  echo >&2 "configure-pivy.sh: need debug or release"
  exit 1
fi
