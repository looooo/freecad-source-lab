This repository exists to build **FreeCAD** and its dependencies **without requiring deep prior knowledge**. The workflow is driven by **Pixi** tasks in the **`debug`** and **`release`** environments; the usual full build is documented in **`INSTRUCTIONS.md`** (e.g. `pixi run -e debug debug` and `pixi run -e release release`).

The first goal is to build **FreeCAD** and the core stack **from source** (e.g. OCCT, Coin3D, Pivy, SMESH, Netgen), with other libraries supplied by the Pixi/conda environment where appropriate. Later, the same structure can be extended to additional components (Qt, Boost, etc.) if needed.

Everything should be buildable in either **debug** or **release** mode, implemented as two separate Pixi environments.

For each source-based component there should be dedicated commands (e.g. `pixi run -e release release-<project>`). Commands are split into **configure**, **build**, and **install** steps (`pixi run -e <debug|release> <configure|build|install>-<debug|release>-<project>`), and combined into a single meta task per component (`pixi run -e <debug|release> <debug|release>-<project>`).

Sources should be tracked as **Git submodules**. To avoid bloating disk usage, use **shallow** clones (e.g. `--depth 1`) when fetching submodules.
