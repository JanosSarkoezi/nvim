# LOG.md - Fortschritt & Änderungen
## [2026-05-03] - Dokumentation & README
### Hinzugefügt
- **README.md**: Erstellung einer umfassenden Dokumentation, die die Philosophie (Buffer-First), die Features (Picker, Git, Wiki, Mark Manager) und die Projektstruktur erklärt.
- **Projekt-Übersicht**: Zusammenfassung der wichtigsten Keymaps und Anforderungen für neue Nutzer.

## [2026-05-03] - Mark Manager Refactoring (Buffer-lokale Isolation)
- **Buffer-lokale Rotation**: Die automatische Vergabe von lokalen Marks (`a-e`) via `<Leader>m` ist nun isoliert pro Datei. Jede Datei hat ihre eigene Rotations-Historie.
- **Isoliertes Pinning**: Das Pinnen von Marks (`p` im Mark Manager) für `a-e` gilt nun ebenfalls nur für die jeweilige Datei.
- **Globale Marks**: Marks `A-E` rotieren weiterhin global über alle Dateien hinweg.
- **Technische Umsetzung**: Nutzung von `vim.b` (buffer-local variables) zur Speicherung des Mark-Status, um die globale "Verschmutzung" der Mark-Rotation zu verhindern.

## [2026-05-02] - Automatisierter Mark Manager (Buffer-First)
### Hinzugefügt
- **Automatisierte Mark-Rotation**: `<Leader>m` (lokal) und `<Leader>n` (global) setzen nun automatisch Marks in einem rotierenden System (`a-e` bzw. `A-E`). Es wird immer das älteste, unbenutzte Register gewählt.
- **Pinning-System**: Im Mark Manager (`<Leader>mm`) können Marks mit `p` gepinnt werden. Gepinnte Marks werden von der automatischen Rotation ausgeschlossen und bleiben dauerhaft erhalten.
- **Mark Manager UI**: 
    - Zeigt `[L]` für gepinnte Marks.
    - **Buffer-First Löschen**: `dd` im Picker löscht das Mark sofort aus Vim und dem UI, ohne das Fenster zu schließen oder zu flackern.
    - Statuszeile im Picker zeigt verfügbare Befehle an: `(p=Pin/Unpin, dd=Delete, CR=Jump)`.
- **LRU-Logik**: Beim Springen zu einem Mark via `<CR>` im Picker wird dieses als "neu" markiert, sodass es bei der nächsten automatischen Zuweisung als letztes überschrieben wird.
## [2026-04-24] - Neue Features: Buffer-First Tools (Git, Quickfix, Terminal, Wiki)
### Hinzugefügt
- **Interaktiver Git-Status**: `<Leader>gs` erlaubt nun das Stagen (`s`) und Unstagen (`u`) von Dateien direkt im Picker.
- **Git Branch-Switcher**: `<Leader>gc` (Checkout) zeigt alle Branches im Picker an.
- **Git Stash-Picker**: `<Leader>gh` zeigt Stashes an. Auswahl macht `apply`, `d` macht `drop`.
- **Puffer-Picker**: `<Leader>fb` öffnet eine Liste aller geladenen Puffer im Picker.
- **Quickfix-Picker**: `<Leader>fq` lädt die aktuelle Quickfix-Liste in den Picker zur Bearbeitung/Filterung.
- **Terminal-Toggle**: `<Leader>t` öffnet/schließt ein Terminal-Fenster am unteren Rand. Der Terminal-Puffer bleibt im Hintergrund erhalten.
- **Wiki-Backlinks**: `<Leader>wb` sucht nach allen Dateien, die auf die aktuelle Notiz verweisen, und zeigt sie im Picker an.
### Behoben
- **Wiki-Links**: Die Link-Erkennung in `core_tools.lua` priorisiert nun den Link direkt unter dem Cursor statt immer nur den ersten in der Zeile.
- **Statusline**: In `options.lua` auf dynamische Evaluierung (`%!v:lua.statusline()`) umgestellt.
- **Faltung**: Redundante `foldexpr` Zuweisung in `options.lua` entfernt.
- **Keymaps**: `expr = true` bei dummy F1-Mappings entfernt, um Ausführungsfehler zu vermeiden.
- **Keymap-Übersicht**: Zeigt nun sowohl globale als auch Puffer-lokale Mappings an.
### Geändert
- **API-Modernisierung**: `nvim_buf_set_option` durch `nvim_set_option_value` in `core_tools.lua` ersetzt.
- **Git-Robustheit**: Prüfung auf Git-Repository nutzt nun `vim.v.shell_error` für zuverlässigere Fehlererkennung.
### Hinzugefügt
- **Git Log (Projekt)**: `<Leader>ga` zeigt das gesamte Projekt-Log im Picker an. Auswahl öffnet den kompletten Commit-Diff.
- **DYNAMISCHES Git Log**: `<Leader>gl` erkennt nun automatisch, ob ein Puffer offen ist. Falls nicht, wird das Projekt-Log statt eines Fehlers angezeigt.
### Geändert
- **Log-Funktionen**: `M.git_log` in `core_tools.lua` modularisiert, um Datei- und Projekt-Kontext zu unterstützen.
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
