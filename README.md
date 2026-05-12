# mini-nvim

Eine modulare, minimalistische Neovim-Konfiguration mit einem Fokus auf **Buffer-First UI** und native Power. 

Dieses Setup verzichtet bewusst auf schwere UI-Plugins und nutzt stattdessen die integrierten Funktionen von Neovim kombiniert mit mächtigen Shell-Tools wie `fd` und `rg`.

## Philosophie

- **Modularer Minimalismus**: Die Logik ist sauber in spezialisierte Module getrennt. Kein unnötiger Ballast.
- **Buffer-First UI**: Anstatt starrer Pop-up-Menüs nutzt diese Konfiguration temporäre "Scratch-Buffer" für Suchen, Listen und Auswahlen.
    - Navigation mit Standard-Vim-Befehlen (`/`, `?`, `G`, `gg`).
    - Fenster-Schutz via `winfixbuf` gegen versehentliches Überschreiben.
    - Singleton-Prinzip: Verhindert redundante Fenster-Instanzen.
- **Native Power**: Volle Nutzung des integrierten Package-Systems, der Quickfix-Liste und moderner API-Features.

## Wichtige Keymaps

### Suche & Navigation
| Keymap | Aktion | Tool |
| :--- | :--- | :--- |
| `<Leader>ff` | Dateien suchen | `fd` |
| `<Leader>fb` | Puffer auswählen | Native |
| `<Leader>fg` | Live Grep | `rg` |
| `<Leader>fd` | Verzeichnis wechseln | `fd` |
| `<Leader>fp` | Projekt wechseln | `fd` |
| `<Leader>fq` | Quickfix bearbeiten | Picker |

### Git Tools
| Keymap | Aktion | Beschreibung |
| :--- | :--- | :--- |
| `<Leader>gs` | Git Status | s=Stage, u=Unstage, l=Log, CR=Diff |
| `<Leader>gl` | Git Log (Datei) | Historie der aktuellen Datei |
| `<Leader>ga` | Git Log (Projekt) | Gesamtes Projekt-Log |
| `<Leader>gL` | Git Log (Range) | Historie für markierten Bereich |
| `<Leader>gb` | Git Blame | Info zur aktuellen Zeile |
| `<Leader>gc` | Git Checkout | Branch-Switcher |
| `<Leader>gh` | Git Stash | Liste; CR=Apply, d=Drop |

### Mark Manager
| Keymap | Aktion | Register |
| :--- | :--- | :--- |
| `<Leader>ml` | Mark setzen (Auto) | Lokal (`a-e`) |
| `<Leader>mg` | Mark setzen (Auto) | Global (`A-E`) |
| `<Leader>mm` | Mark Manager | p=Pin, dd=Delete, CR=Jump |

### Wiki & System
| Keymap | Aktion | Beschreibung |
| :--- | :--- | :--- |
| `<Leader>wp` | Wiki Link öffnen | Folgt `[[link]]` |
| `<Leader>wb` | Wiki Backlinks | Sucht Verweise auf aktuelle Datei |
| `<Leader>t` | Terminal Toggle | Terminal am unteren Rand |
| `<Leader>?` | Hilfe | Keymap-Übersicht anzeigen |

## Struktur

Das Projekt ist modular aufgebaut, um Wartbarkeit und Übersichtlichkeit zu gewährleisten:

```text
~/.config/nvim/
├── init.lua           -- Einstiegspunkt & Plugin-Management
├── lua/
│   ├── options.lua    -- Native Einstellungen (vim.opt)
│   ├── keymaps.lua    -- Zentrale Keybindings
│   ├── core_tools.lua -- Fassade für alle Tools
│   └── core/          -- Spezialisierte Module
│       ├── picker.lua -- Herzstück: Buffer-UI
│       ├── search.lua -- Suche & Navigation
│       ├── git.lua    -- Git-Integration
│       ├── marks.lua  -- Mark-Management
│       ├── wiki.lua   -- Wissensmanagement
│       └── misc.lua   -- Hilfe & Terminal
└── LOG.md             -- Chronologisches Änderungsprotokoll
```

## Anforderungen

- **Neovim 0.10+**
- **fd**: Für Dateisuche.
- **ripgrep (rg)**: Für Textsuche.
- **git**: Für Versionsverwaltung.

---
*Für eine detaillierte Historie der Änderungen siehe [LOG.md](./LOG.md).*
