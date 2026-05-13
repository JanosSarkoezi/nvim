# GEMINI.md - Neovim Configuration Context

## 1. Philosophie & Architektur
- **Modularer Minimalismus**: Logik wird in `lua/` und spezialisierten Modulen in `lua/core/` getrennt. Kein Bloat, klare Struktur.
- **Buffer-First UI**: Statt starrer Pop-ups nutzen wir "Scratch-Buffer" für Suchen und Listen. Das erlaubt Filtern mit `/`, `dd` zum Entfernen von Einträgen und die normale Vim-Navigation.
- **Native Power**: Nutzung des integrierten Package-Systems (`vim.pack`) und der Quickfix-Liste.

## 2. Ordnerstruktur
```text
~/.config/nvim/
├── init.lua           -- Einstiegspunkt, lädt Module
├── GEMINI.md          -- Dieser Kontext für LLMs
├── LOG.md             -- Chronik der Änderungen & Entscheidungen
├── Ideen.md           -- Brainstorming & zukünftige Features
├── README.md          -- Projektübersicht
└── lua/
    ├── options.lua    -- vim.opt Einstellungen
    ├── keymaps.lua    -- Globale Leader-Mappings
    ├── core_tools.lua -- Übergreifende Hilfsfunktionen
    └── core/          -- Modularisierte Kern-Logik
        ├── git.lua    -- Git-Integration (Diff, Blame, etc.)
        ├── marks.lua  -- Mark-Management
        ├── misc.lua   -- Verschiedene kleine Helfer
        ├── picker.lua -- Zentrale Buffer-Picker Logik
        ├── search.lua -- Grep/Ripgrep Integration
        └── wiki.lua   -- Wiki-Logik & Zettelkasten
```

## 3. Tool-Spezifikationen (für LLM-Generierung)
### Buffer-basierte Auswahl (M.open_picker)
Jede Suche (Dateien, Puffer, Projekte) soll über die zentrale Funktion in `lua/core/picker.lua` laufen, die:
1. Einen neuen temporären Buffer erstellt (`buftype=nofile`).
2. Die Ergebnisse dort hineinschreibt.
3. Lokale Keymaps setzt:
   - `<CR>`: Wählt den Eintrag unter dem Cursor aus und schließt den Buffer.
   - `q` / `<Esc>`: Bricht ab.
   - Der Benutzer kann Standard-Vim-Befehle (`/`, `d`, `G`) zum Filtern nutzen.

### Wiki & Projekt-Logik
- **Wiki**: Unterstützung für `[[link]]` mit automatischer Verzeichniserstellung (siehe `lua/core/wiki.lua`).
- **Projekt-Anker**: Suche nach Verzeichnissen wie `liquibase/` oder `.git/` via `fd`.

## 4. Coding-Standard
- Nutze `vim.api` für Buffer-Manipulationen.
- Vermeide externe Plugin-Abhängigkeiten, wo Shell-Tools (`fd`, `rg`) ausreichen.
- Pfade immer relativ zum Projekt-Root (`cwd`) anzeigen.

## 5. Dokumentation & Fortschritt
- **LOG.md**: Führe eine chronologische Liste aller wichtigen Änderungen, neuen Features und Entscheidungen in `LOG.md`. Dies dient als Gedächtnisstütze für den Projektfortschritt.

## 6. Bemerkungen zum Workflow
- **Diskussions-Modus**: Wenn ein Satz mit einem **"D"** endet, dient dies als Signal für eine reine Diskussion. In diesem Fall sollen keine Code-Anpassungen oder Änderungen am Projekt vorgenommen werden.
