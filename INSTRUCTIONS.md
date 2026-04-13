# Instructions: Pixi-based FreeCAD build from source

This document turns the goals in `manifest.md` into a practical workflow.

## Goal

This repository should let you build **FreeCAD** and its core dependencies **without deep prior knowledge**. The usual entry points are the **stack tasks** `debug` and `release` (see below). You can also run configure / build / install per component.

## 1. Pixi environments

- Two environments are defined: **`debug`** and **`release`**, with different compiler and CMake settings (optimization, debug symbols, etc.).
- Component tasks run in the matching environment: `pixi run -e debug …` or `pixi run -e release …`.

## 2. Sources (Git submodules, shallow)

- **Requirement:** The project root must be a **Git repository** (`.git` present). Create one with `pixi run git-init`, or **clone** this repo instead of copying files only. Without `.git`, `submodules-init` / `submodules-status` fail with a clear error.
- Each upstream source lives as its own **Git submodule** under a fixed path (here: `third_party/<name>`).
- Use **shallow clones** (`--depth 1` via `submodules-init`) so the superproject does not pull full histories. Example commands for adding submodules are in `third_party/SUBMODULES.txt`.
- **Fetch submodules:** `pixi run submodules-init` uses `--depth 1` and `--recursive` (nested submodules, e.g. FreeCAD, SMESH). The checked-out revision is the one **pinned by this repo** (see `.gitmodules`). To move to a newer upstream, update the submodule pointer in the superproject, then run `submodules-init` again. Submodule status: `pixi run submodules-status`. These tasks use the **default** Pixi environment (no `-e debug` / `-e release` required).

## 3. Scope (what is built from source)

- The stack includes **FreeCAD** and dependencies such as **OCCT, Coin3D, Pivy, SMESH, Netgen**, wired through `pixi.toml` and CMake.
- Many **host** libraries still come from **conda-forge** via Pixi (see `pixi.toml`). Optional future extensions (e.g. building Qt or Boost from source) can follow the same pattern.

## 4. Task layout (Pixi)

Tasks live in **`[feature.debug.tasks]`** and **`[feature.release.tasks]`** and are only available in the corresponding environment. Names follow **`configure-<mode>-<project>`**, **`build-<mode>-<project>`**, **`install-<mode>-<project>`**, and meta tasks **`<mode>-<project>`** that chain configure → build → install.

| Step | Debug | Release |
|------|--------|---------|
| Configure | `pixi run -e debug configure-debug-<name>` | `pixi run -e release configure-release-<name>` |
| Build | `pixi run -e debug build-debug-<name>` | `pixi run -e release build-release-<name>` |
| Install | `pixi run -e debug install-debug-<name>` | `pixi run -e release install-release-<name>` |
| All three | `pixi run -e debug debug-<name>` | `pixi run -e release release-<name>` |

`<name>` is one of: `occt`, `coin`, `netgen`, `smesh`, `pivy`, `freecad` (see `pixi.toml` for the exact list).

**SMESH** runs **`prepare-smesh`** (Python helper) before configure; that is hooked via `depends-on` on the SMESH configure tasks.

## 5. Full stack (aggregated tasks)

The script `scripts/install-stack.sh` builds and installs the main chain **in order**: **Coin → Pivy → OCCT → SMESH → FreeCAD**. The **`debug`** and **`release`** tasks **depend on `submodules-init`**, so `git submodule update --init --recursive --depth 1` runs first (same as `pixi run submodules-init`).

```bash
pixi run -e debug debug       # full debug stack
pixi run -e release release   # full release stack
```

**Netgen** is **not** part of that chain. Install it separately when needed:

```bash
pixi run -e debug debug-netgen
pixi run -e release release-netgen
```

(Netgen installs into **`$CONDA_PREFIX`** for the active Pixi environment, not under `install/debug` or `install/release`; see comments in `pixi.toml`.)

Other helpers:

- **Parallel CMake build jobs:** `pixi run set-parallel N` (without a number: uses `nproc`, writes `.pixi-build-parallel`). Pivy builds use **`--parallel 1`** regardless.

## 6. Technical notes

- **OCCT** is configured with the **Draw** module (Tcl/Tk test harness) enabled. The Pixi env includes **`tk`** from conda-forge. OCCT’s CMake clears `3RDPARTY_TCL_LIBRARY` / `3RDPARTY_TK_LIBRARY` unless the matching **`3RDPARTY_*_LIBRARY_DIR`** is also set — the `configure-*-occt` tasks set both so linking uses the conda libraries (see `third_party/occt/adm/cmake/tcl.cmake` / `tk.cmake`).
- Use separate install prefixes per mode where applicable (e.g. `install/debug` vs `install/release` under the project root, and/or `$CONDA_PREFIX` for components installed into the Pixi env — see `pixi.toml`).
- Pass **`CMAKE_BUILD_TYPE`**, **`CMAKE_INSTALL_PREFIX`**, and **`CMAKE_PREFIX_PATH`** as needed so already-built dependencies are found.
- Prefer **upstream** READMEs, `BUILDING.md`, and CI scripts for project-specific CMake flags; keep this repo focused on orchestration.
- Re-running configure/build should be safe without manual cleanup where possible.

## 7. Cursor / AI context

- Submodule trees can be **very large**; they are usually excluded from the editor index (e.g. `.cursorignore` on `third_party/`). Treat **`pixi.toml`**, **`INSTRUCTIONS.md`**, and helper scripts as the “infra” surface for search and assistants.
