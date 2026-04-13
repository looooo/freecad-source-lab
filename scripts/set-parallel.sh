#!/usr/bin/env bash
# Speichert die gewünschte Job-Anzahl für cmake --build --parallel.
# Aufruf: pixi run set-parallel [N]
#   N fehlt → nproc (oder 4 als Fallback)
# Pixi hängt Argumente an den Task-Befehl an → $1 ist die Zahl, wenn vorhanden.

set -euo pipefail

root="${PIXI_PROJECT_ROOT:-$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)}"
file="${root}/.pixi-build-parallel"

if [ "$#" -ge 1 ]; then
  n="$1"
else
  n="$(nproc 2>/dev/null || echo 4)"
fi

if ! [[ "$n" =~ ^[0-9]+$ ]] || [ "$n" -lt 1 ]; then
  echo >&2 "set-parallel: positive integer required, got: $n"
  exit 1
fi

printf '%s\n' "$n" >"$file"
echo "pixi: parallel jobs = $n (written to ${file})"
