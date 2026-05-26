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

The configuration uses mnemonic keymaps for easier recall:
- `b` (Buffer)
- `f` (Find)
- `g` (Git)
- `m` (Marks)
- `q` (Quickfix/Quit)
- `w` (Wiki)

### Buffer (b)
| Keymap | Action | Description |
| :--- | :--- | :--- |
| `<Leader>bw` | Buffer Write | Save current buffer |
| `<Leader>bd` | Buffer Delete | Close current buffer |
| `<Leader>bn` | Buffer Next | Go to next buffer |
| `<Leader>bp` | Buffer Previous | Go to previous buffer |
| `<Leader>bl` | Buffer List | Select buffer from picker |

### Find & Navigation (f)
| Keymap | Action | Tool |
| :--- | :--- | :--- |
| `<Leader>ff` | Find Files | `fd` |
| `<Leader>fg` | Find Grep (Live) | `rg` (interactive prompt) |
| `<Leader>fd` | Find Directory | Search directories with `fd` |
| `<Leader>fp` | Find Project | Search for Git projects |
| `<Leader>fP` | Find Pinned | List your pinned projects |
| `<Leader>fa` | Find Add | Pin the current project |
| `<Leader>fG` | Find Multi-Grep | Search across all pinned projects |

### Git Tools (g)
| Keymap | Action | Description |
| :--- | :--- | :--- |
| `<Leader>gs` | Git Status | **s**tage, **u**nstage, **l**og, **CR**=Diff |
| `<Leader>gl` | Git Log (File) | History of the current file |
| `<Leader>ga` | Git Log (All) | Project-wide history |
| `<Leader>gL` | Git Log (Range) | History for visual selection |
| `<Leader>gb` | Git Blame | Info for the current line |
| `<Leader>gc` | Git Checkout | Branch switcher |
| `<Leader>gh` | Git Stash | **CR**=Apply, **d**rop |

**Hinweis zum Git Diff:** Wenn du einen Diff betrachtest (via `<Leader>gs` -> `CR`), kannst du auf jeder hinzugefügten oder Kontext-Zeile `CR` drücken, um direkt an diese Stelle in der Quelldatei zu springen. Die Datei öffnet sich in einem Master-Detail-Layout (Quelldatei links, Diff rechts).

### Mark Manager & Jumps (m)
| Keymap | Action | Description |
| :--- | :--- | :--- |
| `<Leader>ml` | Mark Local (Auto) | Set local mark (`a-e`) |
| `<Leader>mg` | Mark Global (Auto) | Set global mark (`A-E`) |
| `<Leader>mm` | Mark Manager | **p**in, **dd**=Delete, **CR**=Jump |
| `<Leader>mj` | Mark Jumps | Browse the jumplist |

### Quickfix & Quit (q)
| Keymap | Action | Description |
| :--- | :--- | :--- |
| `<Leader>ql` | Quickfix List | Open current list in picker |
| `<Leader>qn` | Quickfix Next | Switch to newer quickfix list |
| `<Leader>qp` | Quickfix Prev | Switch to older quickfix list |
| `<Leader>qq` | Quit | Exit Neovim |
| `<UP>` / `<DOWN>` | QF Navigate | Move through quickfix entries |
| `<LEFT>` / `<RIGHT>` | QF Window | Open (`:cope`) / Close (`:cclo`) |

### Wiki & System (w)
| Keymap | Action | Description |
| :--- | :--- | :--- |
| `<Leader>ww` | Wiki Page Open | Follows `[[link]]` |
| `<Leader>wb` | Wiki Backlinks | Search for references |
| `<Leader>h` | Help: Hide | Clear search highlighting |
| `<Leader>t` | Terminal Toggle | Bottom terminal split |
| `<Leader>?` | Help: Keymaps | Show all keymap overview |

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
