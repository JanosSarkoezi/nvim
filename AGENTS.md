# AGENTS.md - Kontext für Coding-Agenten & LLMs

Diese Datei ist der **maßgebliche Kontext** für alle LLM-gestützten Arbeiten an dieser Neovim-Konfiguration. `GEMINI.md` verweist nur hierher. Gilt neben, nicht statt: [README.md](./README.md) (Nutzer-Doku), [LOG.md](./LOG.md) (Historie), [Ideen.md](./Ideen.md) (Roadmap).

## 1. Philosophie & Architektur

- **Modularer Minimalismus**: Logik in `lua/`, spezialisierte Module in `lua/core/`. Kein Bloat, klare Struktur. `lua/core_tools.lua` ist nur eine Fassade (Proxy), die die Module exportiert — neue Logik gehört in ein Modul, nicht in die Fassade.
- **Buffer-First UI**: Statt Pop-up-Plugins nutzen wir "Scratch-Buffer" für Suchen und Listen. Das erlaubt Filtern mit `/`, `dd` zum Entfernen von Einträgen und normale Vim-Navigation.
- **Native Power**: Nutzung des integrierten Paket-Systems (`vim.pack`), der Quickfix-Liste (inkl. Stack via `:colder`/`:cnewer`) und moderner API-Features (`winfixbuf`, `vim.keymap.set`, `nvim_set_option_value`).

## 2. Ordnerstruktur

```text
~/.config/nvim/
├── init.lua           -- Einstiegspunkt, lädt Module + vim.pack-Plugins + Git-Gutter-Setup
├── AGENTS.md          -- Dieser Kontext (maßgeblich für LLMs)
├── GEMINI.md          -- Verweis auf AGENTS.md (für Gemini CLI)
├── LOG.md             -- Chronik der Änderungen & Entscheidungen
├── Ideen.md           -- Brainstorming & zukünftige Features
├── README.md          -- Projekt-Übersicht & Keymap-Referenz
└── lua/
    ├── options.lua    -- vim.opt Einstellungen + native Statusline
    ├── keymaps.lua    -- Globale Leader-Mappings (zentral, mnemonisch)
    ├── core_tools.lua -- Fassade: exportiert alle core/-Module
    └── core/          -- Modularisierte Kern-Logik
        ├── git.lua    -- Git-Integration (Diff, Blame, Gutter-Signs, etc.)
        ├── jumps.lua  -- Jumplist-Picker
        ├── marks.lua  -- Mark-Management
        ├── misc.lua   -- Keymap-Übersicht, Terminal-Toggle
        ├── picker.lua -- Zentrale Buffer-Picker Logik (M.open_picker)
        ├── search.lua -- fd/rg-Suche, Projekte, Quickfix-Integration
        └── wiki.lua   -- Wiki-Logik & Zettelkasten
```

Bei Abweichungen gilt die **reale Struktur**; dieser Abschnitt und der Struktur-Abschnitt der README.md sind synchron zu halten.

## 3. Tool-Spezifikationen (für LLM-Generierung)

### Buffer-basierte Auswahl (M.open_picker)

Signatur: `open_picker(items, title, callback, extra_mappings, auto_search)` in `lua/core/picker.lua`.

1. Erstellt einen temporären Scratch-Buffer (`buftype=nofile`, `bufhidden=wipe`) — Singleton-Prinzip: existiert bereits ein Fenster mit dem Buffer, wird nur der Fokus dorthin gesetzt.
2. Schreibt die Ergebnisse in den Buffer, öffnet unten ein `botright 12split` und setzt `winfixbuf` (Fenster bleibt dem Tool vorbehalten).
3. Lokale Keymaps:
    - `<CR>`: Wählt den Eintrag unter dem Cursor aus und schließt das Fenster.
    - `q` / `<Esc>`: Schließt das Fenster.
    - `<C-q>`: Überträgt alle Zeilen als **neue** Quickfix-Liste in den Stack (`efm = "%f:%l:%c:%m,%f"`) und öffnet `:copen`.
    - `extra_mappings`: Modul-spezifische Aktionen (z. B. `s`/`u` im Git-Status, `dd` im Mark-Manager).
4. **`auto_search`**: Wenn `true`, startet der Picker direkt im Suchmodus (`/`) — sofortiges Tippen filtert die Einträge. Für fast alle Picker Standard. **Wichtig für die `<Esc>`-Semantik**: Bei `auto_search` beendet das erste `<Esc>` nur die Suche (natives Verhalten im Suchmodus); erst ein weiteres `q`/`<Esc>` schließt den Picker.

Jede neue Suche/Auswahl (Dateien, Buffer, Projekte, …) soll über `M.open_picker` laufen und in `core_tools.lua` exportiert werden, damit `keymaps.lua` sie nutzen kann.

### Wiki & Projekt-Logik

- **Wiki**: Unterstützung für `[[link]]` mit automatischer Verzeichniserstellung (siehe `lua/core/wiki.lua`). Link-Erkennung priorisiert den Link unter dem Cursor.
- **Projekt-Anker**: Suche nach Git-Projekten via `fd`.
- **Gepinnte Projekte**: Persistenter Speicherort ist `stdpath("data")` → `~/.local/share/nvim/projects` (**nicht** `~/.config/nvim/projects` — das ist ein alter, überholter Pfad).

## 4. init.lua-Besonderheiten (in der README-Struktur nicht sichtbar)

- **Plugins via `vim.pack.add`** (daher Neovim 0.12+): `nvim-treesitter` (inkl. `PackChanged`-Autocmd, das bei Updates `TSUpdate` auslöst) und `tokyonight.nvim` (Colorscheme).
- **Git-Gutter**: `require("core.git").setup_gutter()` — native Anzeige von Änderungen (`+`, `~`, `_`) über `git diff -U0` und die `sign`-API; Aktualisierung bei `BufReadPost`, `BufWritePost`, `FocusGained`. Kein `gitsigns.nvim`.
- **`:make`-Workflow ist Maven-konfiguriert**: `makeprg=mvn clean install -Dmaven.test.skip=true -q -f pom.xml` mit einem Maven-`errorformat`. Bei generischen Aufgaben nicht als Vorbild nehmen — das ist eine persönliche Arbeitsumgebung.

## 5. Coding-Standard

- Nutze `vim.api` / `vim.keymap.set` / `nvim_set_option_value` für Buffer- und Option-Manipulationen (nicht die veralteten `nvim_buf_set_option`-Varianten).
- Vermeide externe Plugin-Abhängigkeiten, wo Shell-Tools (`fd`, `rg`, `git`) ausreichen.
- Pfade immer relativ zum Projekt-Root (`cwd`) anzeigen.
- Neue Keymaps bekommen ein `desc`-Attribut und folgen dem mnemonischen Präfix-System (`b`/`f`/`g`/`m`/`q`/`w`), damit die `<Leader>?`-Übersicht sauber gruppiert.

## 6. Dokumentations-Pflichten

- **LOG.md**: Jede wichtige Änderung, jedes neue Feature und jede Entscheidung bekommt einen **datierten Eintrag am Dateianfang** (neueste oben). Das LOG ist die Historie — die aktuelle Referenz für Keymaps/Struktur ist die README.md.
- **Struktur-Sync**: Neue Module in Abschnitt 2 hier **und** im README-Strukturdiagramm aufnehmen; neue Keymaps in die README-Tabellen.
- **Ideen.md**: Erledigte Ideen in die "Erledigt"-Sektion verschieben, nicht zwischen offenen Punkten lassen.

## 7. Workflow-Signale

- **Diskussions-Modus**: Endet ein Satz mit einem **"D"**, ist das ein Signal für eine reine Diskussion — in diesem Fall keine Code-Anpassungen oder Projekt-Änderungen vornehmen.
