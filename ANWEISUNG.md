# Anweisung: Pixi-basierter FreeCAD-Build aus Quellen

Diese Datei setzt die Ziele aus `manifest.md` in eine umsetzbare Vorgehensweise um.

## Ziel

Dieses Repository soll den Bau von FreeCAD und seinen Kernabhängigkeiten **ohne tiefes Vorwissen** ermöglichen. Am Ende soll der Nutzer nur **`pixi run -e debug debug-all`** bzw. **`pixi run -e release release-all`** ausführen müssen (Tasks hängen an den Pixi-Umgebungen `debug` und `release`, nicht an der default-Umgebung).

## 1. Pixi-Umgebungen

- Lege **zwei getrennte Pixi-Environments** an (z. B. `debug` und `release`), die sich in Compiler- und CMake-Flags unterscheiden (Optimierung, Debug-Symbole, Assertions; ggf. zusätzliche Debug-Checks nur im Debug-Modus).
- Alle Tasks (configure/build/install) laufen in dem Environment, das zum gewünschten Modus passt.

## 2. Quellen (Git-Submodule, flach)

- **Voraussetzung:** Dieses Verzeichnis muss ein **Git-Repository** sein (Ordner `.git`). Neu anlegen: **`pixi run git-init`**, oder das Projekt **klonen** statt nur Dateien zu kopieren. Ohne `.git` melden `submodules-init` / `submodules-status` einen klaren Fehler statt der Git-Meldung „Kein Git-Repository“.
- Verwalte **jede Quellabhängigkeit als eigenes Git-Submodule** unter einem festen Pfad (z. B. `third_party/<name>` oder `sources/<name>`).
- Nutze **flache Klone** (`git submodule add` mit `--depth 1` bzw. nachträglich shallow konfigurieren), damit das Repository **nicht durch volle Histories** aufbläht. Beispielbefehle zum Anlegen stehen in `third_party/SUBMODULES.txt`.
- **Einladen der Submodule:** **`pixi run submodules-init`** nutzt **`--depth 1`**: es werden nur die für den jeweiligen Checkout nötigen Objekte geholt (**flacher Klon**, keine volle Historie). Der ausgecheckte Stand ist der im **Parent-Repository festgelegte** Submodule-Commit (wie in `.gitmodules` / Superproject referenziert) — wenn du einen neueren Upstream-Stand willst, Parent-Repo aktualisieren oder Submodule-Zeiger anpassen, dann erneut `submodules-init`. **`--recursive`** lädt verschachtelte Submodule (z. B. in FreeCAD) ebenfalls flach mit. Status: **`pixi run submodules-status`**. Tasks in der **Default**-Umgebung (kein `-e debug` / `-e release` nötig).

## 3. Erste Baustufe (Scope)

- Baue zunächst **aus Quellen**: **FreeCAD** sowie die nächsten Abhängigkeiten: **pivy, Coin, scmesh, netgen, OCCT**. Reihenfolge und Install-Prefixe so wählen, dass spätere Pakete die vorher installierten finden.
- Erweiterungen (z. B. **Qt, Boost** aus Quelle) sind **später** optional derselben Struktur hinzuzufügen.

## 4. Task-Struktur (Pixi)

Die Tasks sind in **`[feature.debug.tasks]`** bzw. **`[feature.release.tasks]`** definiert und sind nur in der jeweiligen Umgebung sichtbar. Der **Modus** steckt im **Task-Namen** (wie in `manifest.md`): `debug` bzw. `release` zwischen Aktion und Projekt bzw. als Kurz-Präfix.

Für **jedes** Projekt `<name>` (z. B. `occt`, `coin`, …):

| Ebene | Debug | Release |
|--------|--------|---------|
| Konfigurieren | `pixi run -e debug configure-debug-<name>` | `pixi run -e release configure-release-<name>` |
| Bauen | `pixi run -e debug build-debug-<name>` | `pixi run -e release build-release-<name>` |
| Installieren | `pixi run -e debug install-debug-<name>` | `pixi run -e release install-release-<name>` |
| Alles nacheinander | `pixi run -e debug debug-<name>` | `pixi run -e release release-<name>` |

Die Einzelschritte sind per **`depends-on`** so verkettet, dass **configure → build → install** und die **Reihenfolge der Projekte** (occt → … → freecad) eingehalten wird.

## 5. Meta-Tasks

- **`pixi run -e debug debug-all`**: führt alle Debug-Projekt-Pipelines zusammen (`debug-occt` … `debug-freecad`); in `pixi.toml` hängt `debug-all` explizit von allen sechs `debug-<name>`-Tasks ab.
- **`pixi run -e release release-all`**: entsprechend für Release (`release-occt` … `release-freecad`).

## 6. Technische Leitplanken

- Installationsverzeichnis pro Modus eindeutig (z. B. gemeinsamer Prefix im Arbeitsverzeichnis oder `install/debug` vs. `install/release`), damit sich Debug und Release nicht überschreiben.
- CMake: `-DCMAKE_BUILD_TYPE`, `-DCMAKE_INSTALL_PREFIX`, ggf. `CMAKE_PREFIX_PATH` für bereits gebaute Abhängigkeiten setzen.
- **Build-Flags und CMake-Optionen** können **direkt aus den jeweiligen Quell-Repositories** (Git-Submodule) übernommen werden: README, `BUILDING.md`, offizielle Build-Doku, `CMakeLists.txt`-Hinweise, CI-/Workflow-Dateien. So bleibt dieses Repo schlank und folgt den Empfehlungen der Upstream-Projekte, ohne Flags hier zu duplizieren.
- Tasks wo sinnvoll **idempotent** gestalten (erneutes configure/build ohne manuelles Aufräumen).

## 7. Cursor / KI-Kontext

- Die **Git-Submodule** (Upstream-Quellen) können **sehr groß** werden und gehören **nicht** in den typischen Arbeitskontext von Cursor: Es soll nur die **Build-Infrastruktur** dieses Repos berücksichtigt werden (`pixi.toml`, diese Anweisung, Konfiguration).
- **Technisch:** Die Verzeichnisse der Submodule in **`.cursorignore`** eintragen (z. B. `third_party/` und `sources/` – passend zur gewählten Pfadkonvention). So bleiben Index, Suche und KI-Vorschläge auf die Infrastruktur begrenzt und werden nicht durch Millionen Zeilen Upstream-Code aufgebläht. Build- und Install-Verzeichnisse können bei Bedarf ebenfalls ausgeschlossen werden.
