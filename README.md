# mini-nvim

Eine modulare, minimalistische Neovim-Konfiguration mit einem Fokus auf **Buffer-First UI** und native Power. 

Dieses Setup verzichtet bewusst auf schwere UI-Plugins und nutzt stattdessen die integrierten Funktionen von Neovim kombiniert mit mächtigen Shell-Tools wie `fd` und `rg`.

## 🚀 Philosophie

- **Modularer Minimalismus**: Die Logik ist sauber in Module unter `lua/` getrennt. Kein unnötiger Ballast.
- **Buffer-First UI**: Anstatt starrer Pop-up-Menüs nutzt diese Konfiguration temporäre "Scratch-Buffer" für Suchen, Listen und Auswahlen. Dies ermöglicht:
    - Navigation mit Standard-Vim-Befehlen (`/`, `?`, `G`, `gg`).
    - Filtern und Bearbeiten der Ergebnislisten (z.B. mit `dd` zum Entfernen).
    - Konsistenz über alle Tools hinweg.
- **Native Power**: Volle Nutzung des integrierten Package-Systems (`vim.pack`), der Quickfix-Liste und Treesitter.
- **Shell-Integration**: Bevorzugung von bewährten Tools (`fd`, `rg`, `git`) gegenüber komplexen Plugin-Abhängigkeiten.

## ✨ Features

### 🔍 Zentraler Picker
Das Herzstück der Konfiguration. Ein universelles Auswahl-Tool für:
- **Dateien (`<Leader>ff`)**: Schnelle Suche mit `fd`.
- **Puffer (`<Leader>fb`)**: Übersicht und Wechsel zwischen geladenen Buffern.
- **Projekte (`<Leader>fp`)**: Schneller Wechsel zwischen Git-Projekten.
- **Live Grep (`<Leader>fg`)**: Projektweite Textsuche mit `rg`.
- **Verzeichnisse (`<Leader>fd`)**: Schneller Wechsel des Arbeitsverzeichnisses.
- **Quickfix-Integration**: `<C-q>` im Picker schiebt alle aktuellen Treffer in die Quickfix-Liste.

### 📝 Wiki & Wissensmanagement
- **Wiki-Links**: Unterstützung für `[[link]]` mit automatischer Verzeichniserstellung (`<Leader>wp`).
- **Backlinks (`<Leader>wb`)**: Findet alle Dokumente, die auf die aktuelle Notiz verweisen.

### 🌿 Git Integration (Buffer-First)
- **Status (`<Leader>gs`)**: Interaktive Liste; `s` zum Stagen, `u` zum Unstagen, `<CR>` für Diff.
- **Log (`<Leader>gl` / `<Leader>ga`)**: Datei- oder Projekthistorie einsehen.
- **Range Log (`<Leader>gL`)**: Historie für markierte Zeilen oder Blöcke (`git log -L`).
- **Blame (`<Leader>gb`)**: Schnelle Info zur aktuellen Zeile.
- **Branches (`<Leader>gc`)**: Branch-Switcher.
- **Stash (`<Leader>gh`)**: Stash-Verwaltung (Apply/Drop).

### 📍 Mark Manager
- **Automatisierte Rotation**: `<Leader>m` (lokal) und `<Leader>n` (global) setzen Marks automatisch in freien oder den ältesten unbenutzten Registern (`a-e` / `A-E`).
- **Verwaltung (`<Leader>mm`)**: Ein UI zum Springen, Löschen (`dd`) oder Pinnen (`p`) von Marks. Gepinnte Marks werden nicht automatisch überschrieben.

### 🛠️ Weitere Highlights
- **Terminal-Toggle (`<Leader>t`)**: Ein schnelles Terminal am unteren Rand.
- **Quickfix-Navigation**: Einfaches Springen mit `<UP>`/`<DOWN>` und Stack-Navigation mit `<Leader>co`/`<Leader>cn`.
- **Treesitter**: Modernes Syntax-Highlighting und intelligentes Folding.
- **Design**: `tokyonight` Colorscheme mit einer minimalistischen, informativen Statusline.

## 📂 Struktur

```text
~/.config/nvim/
├── init.lua           -- Haupteinstiegspunkt & Plugins
├── GEMINI.md          -- Architektur-Kontext für LLMs
├── LOG.md             -- Chronologisches Änderungsprotokoll
└── lua/
    ├── options.lua    -- Native Vim-Einstellungen
    ├── keymaps.lua    -- Zentrale Keybindings
    └── core_tools.lua -- Picker-Logik, Wiki, Git & Mark Manager
```

## 🛠️ Anforderungen

- **Neovim 0.10+** (empfohlen)
- **fd**: Für Dateisuche.
- **ripgrep (rg)**: Für Textsuche.
- **git**: Für die Versionsverwaltungstools.

## ⌨️ Wichtige Keymaps

| Keymap | Beschreibung |
| :--- | :--- |
| `<Leader>ff` | Dateien suchen |
| `<Leader>fg` | Live Grep |
| `<Leader>gs` | Git Status |
| `<Leader>mm` | Mark Manager |
| `<Leader>t` | Terminal ein/aus |
| `<Leader>?` | Alle verfügbaren Keymaps anzeigen |

---

*Für eine detaillierte Historie der Änderungen siehe [LOG.md](./LOG.md).*
