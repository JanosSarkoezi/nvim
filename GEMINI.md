# GEMINI.md - Neovim Configuration Context
## 1. Philosophie & Architektur
- **Modularer Minimalismus**: Logik wird in `lua/*.lua` Dateien getrennt. Kein Bloat, aber klare Struktur.
- **Buffer-First UI**: Statt starrer Pop-ups nutzen wir "Scratch-Buffer" für Suchen und Listen. Das erlaubt Filtern mit `/`, `dd` zum Entfernen von Einträgen und die normale Vim-Navigation.
- **Native Power**: Nutzung des integrierten Package-Systems (`vim.pack`) und der Quickfix-Liste.
## 2. Ordnerstruktur
```text
./mini-nvim/
├── init.lua           -- Lädt Module (options, keymaps, plugins, tools)
├── GEMINI.md          -- Dieser Kontext für LLMs
└── lua/
    ├── options.lua    -- vim.opt Einstellungen
    ├── keymaps.lua    -- Globale Leader-Mappings
    ├── plugins.lua    -- vim.pack.add Definitionen (z.B. Treesitter)
    └── core_tools.lua -- Wiki-Logik, Buffer-Suche, Projekt-Management
```
## 3. Tool-Spezifikationen (für LLM-Generierung)
### Buffer-basierte Auswahl (M.open_picker)
Jede Suche (Dateien, Puffer, Projekte) soll über eine zentrale Funktion laufen, die:
1. Einen neuen temporären Buffer erstellt (`buftype=nofile`).
2. Die Ergebnisse dort hineinschreibt.
3. Lokale Keymaps setzt:
   - `<CR>`: Wählt den Eintrag unter dem Cursor aus und schließt den Buffer.
   - `q` / `<Esc>`: Bricht ab.
   - Der Benutzer kann Standard-Vim-Befehle (`/`, `d`, `G`) zum Filtern nutzen.
### Wiki & Projekt-Logik
- **Wiki**: Unterstützung für `[[link]]` mit automatischer Verzeichniserstellung.
- **Projekt-Anker**: Suche nach Verzeichnissen wie `liquibase/` oder `.git/` via `fd`.
## 4. Coding-Standard
- Nutze `vim.api` für Buffer-Manipulationen.
- Vermeide externe Plugin-Abhängigkeiten, wo Shell-Tools (`fd`, `rg`) ausreichen.
- Pfade immer relativ zum Projekt-Root (`cwd`) anzeigen.
## 5. Dokumentation & Fortschritt
- **LOG.md**: Führe eine chronologische Liste aller wichtigen Änderungen, neuen Features und Entscheidungen in `LOG.md`. Dies dient als Gedächtnisstütze für den Projektfortschritt.
