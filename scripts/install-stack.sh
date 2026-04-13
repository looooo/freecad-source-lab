#!/usr/bin/env bash
# Reihenfolge: Coin → Pivy → OCCT → SMESH → FreeCAD (configure/build/install pro Komponente).
set -euo pipefail
root="${PIXI_PROJECT_ROOT:-$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)}"
cd "$root"
mode="${1:?usage: install-stack.sh debug|release}"
if [ "$mode" = debug ]; then
  env_name=debug
  tasks=(debug-coin debug-pivy debug-occt debug-smesh debug-freecad)
elif [ "$mode" = release ]; then
  env_name=release
  tasks=(release-coin release-pivy release-occt release-smesh release-freecad)
else
  echo >&2 "install-stack.sh: need debug or release"
  exit 1
fi
for t in "${tasks[@]}"; do
  echo >&2 "pixi: === $t ($env_name) ==="
  pixi run -e "$env_name" "$t"
done
