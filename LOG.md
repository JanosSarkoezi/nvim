# LOG.md - Fortschritt & Änderungen

## [2026-04-19] - Picker-Optimierung & Grep-Integration

### Hinzugefügt
- **Live Grep**: Funktion `M.live_grep` in `core_tools.lua` (Keymap `<leader>fg`). Nutzt `rg --vimgrep`.
- **Verzeichnissuche**: Funktion `M.find_directories` (Keymap `<leader>fd`) zum schnellen Wechseln des Arbeitsverzeichnisses (`cd`).
- **Quickfix-Integration**: `<C-q>` im Picker nutzt nun `efm`, um Grep-Ergebnisse (`pfad:zeile:spalte`) korrekt in die Quickfix-Liste zu überführen.
- **Quickfix Stack**: Unterstützung für mehrere Quickfix-Listen (Stack). 
    - `<leader>co`: Gehe zur älteren Liste (`:colder`).
    - `<leader>cn`: Gehe zur neueren Liste (`:cnewer`).
    - In `core_tools.lua` erstellt `<C-q>` nun eine neue Liste im Stack (`setqflist({}, " ")`).

### Geändert
- **Picker-Höhe**: Das Picker-Fenster (`M.open_picker`) ist nun standardmäßig auf 12 Zeilen begrenzt und wird mit `botright` am unteren Rand geöffnet.
- **Keymap-Struktur**: Alle Keymaps aus `core_tools.lua` wurden in die zentrale `lua/keymaps.lua` verschoben, um eine bessere Übersicht zu gewährleisten.
- **Search Clear**: `<leader>h` zum Aufheben der Such-Highlights (`nohlsearch`) integriert.

### Architektur-Entscheidungen
- **Chaining/Narrowing**: Eine experimentelle "Suche in Auswahl"-Funktion wurde nach Nutzertest zurückgerollt, um den Fokus auf Einfachheit zu legen.
- **GEMINI.md Update**: Mandat zur Führung der `LOG.md` hinzugefügt.
