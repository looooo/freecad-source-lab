#!/usr/bin/env bash
# FreeCAD: conda-linux-* preset + extern gebautes SMESH unter install/<mode> (vorher debug-smesh / release-smesh).
set -euo pipefail
mode="${1:?usage: configure-freecad.sh debug|release}"
root="${PIXI_PROJECT_ROOT:-$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)}"
cd "$root/third_party/freecad"

if [ "$mode" = debug ]; then
  prefix="$root/install/debug"
  preset="conda-linux-debug"
elif [ "$mode" = release ]; then
  prefix="$root/install/release"
  preset="conda-linux-release"
else
  echo >&2 "configure-freecad.sh: need debug or release"
  exit 1
fi

# FREECAD_USE_EXTERNAL_SMESH ist im Preset schon ON; SMESH_DIR zeigt auf das Verzeichnis mit SMESHConfig.cmake (siehe install/.../cmake/).
# CMAKE_PREFIX_PATH: zuerst lokaler Stack (OCCT/SMESH/Coin), dann Conda.
# conda-linux-* setzt OCC_* auf $CONDA_PREFIX; ohne Conda-occt müssen OCCT-Header/Libs vom lokalen install/<mode> kommen (z. B. debug-occt).
cmake --preset "$preset" \
  -DPython3_ROOT_DIR="$CONDA_PREFIX" \
  -DPython3_FIND_STRATEGY=LOCATION \
  -DFREECAD_USE_EXTERNAL_SMESH=ON \
  -DSMESH_DIR="$prefix/cmake" \
  -DCMAKE_PREFIX_PATH="${prefix};${CONDA_PREFIX}" \
  -DOCC_INCLUDE_DIR="${prefix}/include/opencascade" \
  -DOCC_LIBRARY_DIR="${prefix}/lib"
