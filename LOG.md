# LOG.md - Fortschritt & Änderungen

## [2026-04-20] - Git-Integration (Buffer-First)

### Hinzugefügt
- **Git Log (Datei)**: `<Leader>gl` öffnet die Historie der aktuellen Datei im Picker. Auswahl zeigt den Commit-Diff in einem Split-Fenster.
- **Git Log (Zeile)**: `<Leader>gL` verfolgt die Entwicklung der aktuellen Zeile (`git log -L`). Zeigt Änderungen direkt im Split-Fenster an.
- **Git Blame (Zeile)**: `<Leader>gb` gibt Autor, Datum und Commit der aktuellen Zeile in der Kommandozeile aus.
- **Git Status**: `<Leader>gs` listet geänderte Dateien im Picker auf. Auswahl öffnet das `git diff` im Split-Fenster.
- **Hilfsfunktion `show_git_output`**: Zentrale Logik in `core_tools.lua` zur Anzeige von Git-Outputs in vertikalen Scratch-Buffern inklusive Syntax-Highlighting (`filetype=diff`).
- **Keymap-Übersicht**: `<Leader>?` zeigt alle definierten Keymaps mit Beschreibung im Picker an. Die Liste wird dynamisch aus den Neovim-Daten generiert.

### Geändert
- **Keymaps**: Erweiterung von `lua/keymaps.lua` um das `<Leader>g` Präfix für alle Git-Operationen.

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
- 2026-04-20: git_log_range implementiert. Unterstützt nun git log -L für markierte Bereiche im Visual Mode (<Leader>gL).
- 2026-04-20: Manuelle Anpassungen in lua/keymaps.lua: F1-Mapping und Fluchtweg aus dem Terminal-Mode (<Esc><Esc>).
