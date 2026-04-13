#!/usr/bin/env bash
# cmake --build <dir> --parallel <N> mit N aus .pixi-build-parallel oder nproc.
set -euo pipefail
root="${PIXI_PROJECT_ROOT:-$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)}"
j=$(cat "${root}/.pixi-build-parallel" 2>/dev/null || nproc 2>/dev/null || echo 4)
cmake --build "$1" --parallel "$j"
