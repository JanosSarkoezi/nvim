# LOG.md - Fortschritt & Änderungen

## [2026-05-12] - Git Status: Log-Integration
- **Feature**: Neuer Shortcut `l` (Log) im Git Status Picker (`<Leader>gs`).
    - Ermöglicht es, die Historie einer geänderten Datei direkt aus der Status-Übersicht heraus einzusehen, ohne die Datei vorher öffnen zu müssen.
    - Öffnet einen neuen Picker mit dem Datei-Log; bei Auswahl eines Commits wird das `git show` für diese Datei angezeigt.
- **Refactoring**: `M.git_log` in `lua/core/git.lua` unterstützt nun einen optionalen Dateipfad (`opts.file`), was die Funktion flexibler für Aufrufe aus anderen Tools macht.

## [2026-05-06] - Mark Manager: Vereinfachung & UI-Polishing
- **Vereinfachte Logik**: Die experimentelle Pinning-Logik und die persistente Speicherung wurden entfernt, um den Mark Manager schlank und wartbar zu halten.
- **UI-Verbesserungen**:
    - **Dynamische Spaltenbreite**: Der Picker berechnet nun automatisch die optimale Breite für die Dateinamen-Spalte basierend auf den vorhandenen Marks.
    - **Inhalts-Vorschau**: Die Vorschau der Zeileninhalte wird nun intelligent gekürzt (`...`), um auch bei langen Zeilen ein sauberes Layout zu gewährleisten.
- **Keymap-Klarheit**: 
    - Trennung der Auto-Mark-Befehle beibehalten:
    - `<Leader>ml`: Setzt ein lokales Mark (`a-e`) automatisch im nächsten freien/ersten Register.
    - `<Leader>mg`: Setzt ein globales Mark (`A-E`) automatisch im nächsten freien/ersten Register.
- **Automatisierung**: `autocmd` zum automatischen Entfernen von Trailing Whitespace beim Speichern in `options.lua` hinzugefügt.

## [2026-05-05] - Mark Manager: Intelligente Mark-Auswahl & Persistenz-Sync
- **Bugfix**: Behebung des Problems, dass globale Marks (A-E) unerwartet überschrieben wurden ("Verschwinden").
- **Intelligente Auswahl**: `set_mark_auto` prüft nun aktiv, welche Marks in Neovim bereits belegt sind. Unbenutzte Marks werden bevorzugt gewählt, bevor das älteste un-gepinnte Mark überschrieben wird.
- **Startup-Sync**: Beim ersten Aufruf des Mark Managers werden bereits existierende Marks (z.B. aus der `shada`-Datei) automatisch in die interne LRU-Liste integriert und als "kürzlich verwendet" markiert. Dies verhindert, dass `A` direkt nach einem Neustart überschrieben wird, nur weil es am Anfang der Liste steht.

## [2026-05-05] - Speicherort für Projekte verschoben & Grep-Flags
- **Refactoring**: Der Speicherort für die Datei `projects` wurde von `stdpath("config")` nach `stdpath("data")` verschoben (`~/.local/share/nvim/projects`).
- **Feature**: `<Leader>fg` (Grep) und `<Leader>fG` (MultiGrep) unterstützen nun Flags (z.B. `-t lua`). Sie funktionieren jetzt wie der native `:grep` Befehl:
    - Wenn man `<Leader>fg` drückt, öffnet sich die Befehlszeile mit `:Grep `.
    - Man kann dort das Suchmuster und Flags eingeben (z.B. `:Grep "mein suchbegriff" -t py`).
    - Ohne Argumente (`:Grep` + Enter) erscheint weiterhin der gewohnte Prompt.

## [2026-05-04] - Project Context & Multi-Grep
- **Feature**: Einführung von "Gepinnten Projekten". Erlaubt es, eine feste Liste von Projektverzeichnissen zu definieren.
- **Multi-Search**: Neues Kommando `<Leader>fG` (Multi-Grep), das gleichzeitig in allen gepinnten Projekten sucht. Ideal für Microservices oder zusammengehörige Repos.
- **Projekt-Management**:
    - `<Leader>fa`: Fügt das aktuelle Verzeichnis zur Projektliste hinzu.
    - `<Leader>fP`: Öffnet einen Picker aller Projekte zum schnellen Wechseln (`cd`) oder zum Entfernen (`dd`).
- **Speicherung**: Die Projekte werden persistent in `~/.config/nvim/projects` gespeichert.

## [2026-05-04] - Native Git Gutter-Signs
- **Feature**: Implementierung einer leichtgewichtigen Gutter-Anzeige für Git-Änderungen (`+`, `~`, `_`).
- **Technik**: Nutzt `git diff -U0` zur Analyse von Änderungen und die native Neovim `sign` API zur Anzeige.
- **Automatisierung**: Automatische Aktualisierung bei `BufReadPost`, `BufWritePost` und `FocusGained`.
- **Minimalismus**: Keine Abhängigkeit von Plugins wie `gitsigns.nvim`; volle Kontrolle über Highlights und Symbole.

## [2026-05-04] - Ideen-Roadmap & Zukunftsplanung
- **Strategische Planung**: Erstellung von `Ideen.md` zur strukturierten Erfassung von Erweiterungsmöglichkeiten für die Konfiguration.
- **Themenschwerpunkte**: Fokus auf LSP-Integration (Outline/Diagnostics), Wiki-Ausbau (Daily Notes/Completion), Workflow-Utilities (Snippets/Sessions) und native UI-Refinements (Statusline).
- **Philosophie**: Sicherstellung, dass alle zukünftigen Features dem "Modularer Minimalismus" und dem "Buffer-First" Prinzip folgen.

## [2026-05-03] - Standfeste UI (winfixbuf Integration)
- **Fenster-Locking**: Integration von `winfixbuf=true` für alle Picker- und Git-Output-Fenster. 
- **Sicherheit**: Verhindert, dass in diesen spezialisierten Fenstern versehentlich andere Puffer (z.B. via `:edit` oder `:bnext`) geöffnet werden. Das Fenster bleibt strikt dem Tool vorbehalten.
- **Voraussetzung**: Nutzt native Features von Neovim 0.10+.

## [2026-05-03] - Bugfix: E95 Buffer already exists (Singleton Pattern)
- **Fokus statt Duplikat**: Wenn ein Picker oder Git-Output-Fenster bereits offen ist, wird kein neuer Puffer erstellt. Stattdessen springt der Fokus direkt in das bereits vorhandene Fenster.
- **Sauberer Neuaufbau**: Falls ein Puffer mit dem Namen zwar existiert, aber nicht sichtbar ist (z.B. versteckt), wird er automatisch gelöscht, damit die neue Instanz den Namen übernehmen kann.
- **UX**: Verhindert redundante Picker-Fenster und spart Ressourcen.

## [2026-05-03] - Modularisierung von core_tools.lua (Divide & Conquer)
- **Struktur-Refactoring**: `lua/core_tools.lua` (598 Zeilen) wurde in ein modulares System unter `lua/core/` aufgeteilt, um die Wartbarkeit zu verbessern.
- **Neue Module**:
    - `lua/core/picker.lua`: Zentrale Picker-Logik (`open_picker`).
    - `lua/core/wiki.lua`: Wiki-Links und Backlinks.
    - `lua/core/search.lua`: Dateisuche, Grep, Projekte, Verzeichnisse und Quickfix-Integration.
    - `lua/core/git.lua`: Git-Status, Logs, Blame, Branches und Stashes.
    - `lua/core/marks.lua`: Mark-Manager mit automatischer Rotation und Pinning.
    - `lua/core/misc.lua`: Terminal-Toggle und Keymap-Übersicht.
- **Abwärtskompatibilität**: `lua/core_tools.lua` fungiert nun als Fassade (Proxy), die alle Funktionen aus den Modulen exportiert. Bestehende Keymaps in `lua/keymaps.lua` funktionieren weiterhin ohne Anpassung.

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
