# Ideen & Roadmap

Dieses Dokument sammelt Konzepte für die Erweiterung der Neovim-Konfiguration, basierend auf der Philosophie des **modularen Minimalismus** und der **Buffer-First UI**.

## 1. LSP & Symbole
- **Document Symbols**: Integration von `vim.lsp.buf_request`, um Funktionen/Variablen im `open_picker` anzuzeigen (Outline-Ansicht).
- **Diagnostics Picker**: Anzeige von LSP-Fehlern/Warnungen im Picker mit Sprungfunktion.
- **Reference Finder**: Auflistung aller Referenzen eines Symbols im Picker.

## 2. Wiki & Wissensmanagement
- **Daily Notes**: Automatisches Erstellen/Öffnen von datumsbasierten Dateien (z. B. `wiki/2026-05-04.md`) mit optionalen Templates.
- **Wiki-Suche**: Dedizierter `rg`-Befehl für den Wiki-Ordner.
- **Link-Completion**: Picker-basierte Auswahl existierender Wiki-Dateien beim Tippen von `[[`.

## 3. Workflow & Utilities
- **Simple Snippets**: Einfügen von Textbausteinen aus einem Snippet-Verzeichnis via Picker.
- **Scratch-Notes**: Schneller Zugriff auf einen globalen temporären Puffer für flüchtige Notizen.
- **Session Manager**: Speichern und Laden von Fenster-Layouts (`:mksession`) via Picker.

## 4. Terminal-Integration
- **Buffer-Terminals**: Funktion zum Öffnen von `:terminal` in benannten Buffern (z. B. `Term: <Verzeichnis>`), um sie über den Buffer-Picker auffindbar zu machen.

## 5. UI & UX Refinement
- **Native Statusline**: Handgebaute Statuszeile in `lua/options.lua` ohne Plugin-Abhängigkeit (Anzeige von Mode, Git, LSP).
- **Quickfix-Editing**: Einträge im Picker mit `dd` löschen und die Quickfix-Liste so interaktiv filtern.

## 6. Git Erweiterungen
- **Commit Browser**: `git log` im Picker anzeigen und Diffs in einem Split-Window via `show_git_output` öffnen.
- [x] **Native Gutter-Signs**: Anzeige von Änderungen am Rand (Sign Column) mittels nativer `sign`-Funktionen und `git diff`.
