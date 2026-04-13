# freecad-source-lab

<p align="center">
  <img src="tux.png" alt="Tux waving hello" width="250">
</p>

Hey, you. Yes, **you** — the human wondering whether building an entire CAD stack from source is a sensible life choice. The answer is: *maybe*, and this repo holds your hand gently along the way (Pixi brings the coffee).

This is all about **FreeCAD** and friends: OCCT, Coin, SMESH, Netgen, Pivy — wired up with **Pixi** so you spend less time on “CMake found my OpenCASCADE in a parallel universe” and more on things that feel like progress.

## The cozy quick start

```bash
pixi run debug  # and wait
pixi run -e debug FreeCAD
```

If that finishes, you’re allowed to feel smug. If it doesn’t: no drama — see [`INSTRUCTIONS.md`](INSTRUCTIONS.md) for the grown-up bits (order of operations, tasks, technical notes).


Good luck, stay curious, and if CMake grumbles again: breathe. Tux believes in you. 🐧
