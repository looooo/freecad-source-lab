#!/usr/bin/env python3
"""Run third_party/smesh/prepare.py without shadowing PyPI 'patch' by the repo's patch/ directory."""
from __future__ import annotations

import os
import sys


def main() -> None:
    root = os.environ.get("PIXI_PROJECT_ROOT")
    if not root:
        root = os.path.abspath(os.path.join(os.path.dirname(__file__), ".."))
    smesh = os.path.join(root, "third_party", "smesh")
    if not os.path.isdir(smesh):
        print("prepare-smesh: third_party/smesh missing — run: pixi run submodules-init", file=sys.stderr)
        sys.exit(1)
    smesh = os.path.normpath(smesh)
    # Remove paths that make `import patch` resolve to ./patch/ (data dir) instead of site-packages.
    filtered: list[str] = []
    for p in sys.path:
        if not p:
            continue
        if os.path.normpath(os.path.abspath(p)) == smesh:
            continue
        filtered.append(p)
    sys.path[:] = filtered
    os.chdir(smesh)
    prep = os.path.join(smesh, "prepare.py")
    with open(prep, encoding="utf-8") as f:
        code = compile(f.read(), prep, "exec")
    g: dict = {"__name__": "__main__", "__file__": prep, "__builtins__": __builtins__}
    exec(code, g)


if __name__ == "__main__":
    main()
