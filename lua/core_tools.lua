-- lua/core_tools.lua
-- Wiki, Projekt-Management und Buffer-basierte Auswahl

local M = {}

-- Zentrale Funktion für Puffer-basierte Auswahl (M.open_picker)
function M.open_picker(items, title, callback)
    -- Neuen Scratch-Puffer erstellen
    local bufnr = vim.api.nvim_create_buf(false, true)
    vim.api.nvim_set_option_value("buftype", "nofile", { buf = bufnr })
    vim.api.nvim_set_option_value("bufhidden", "wipe", { buf = bufnr })
    vim.api.nvim_set_option_value("swapfile", false, { buf = bufnr })
    vim.api.nvim_buf_set_name(bufnr, title or "Picker")

    -- Einträge in den Puffer schreiben
    vim.api.nvim_buf_set_lines(bufnr, 0, -1, false, items)

    -- Puffer anzeigen (unten, mit reduzierter Höhe)
    vim.cmd("botright 12split")
    local winnr = vim.api.nvim_get_current_win()
    vim.api.nvim_win_set_buf(winnr, bufnr)

    -- Lokale Keymaps setzen
    local opts = { buffer = bufnr, silent = true }

    -- <CR> wählt den Eintrag aus
    vim.keymap.set("n", "<CR>", function()
        local cursor_line = vim.api.nvim_win_get_cursor(winnr)[1]
        local selected_item = vim.api.nvim_buf_get_lines(bufnr, cursor_line - 1, cursor_line, false)[1]
        vim.api.nvim_win_close(winnr, true)
        if callback and selected_item ~= "" then callback(selected_item) end
    end, opts)

    -- <C-q> überträgt alle sichtbaren Zeilen in die Quickfix-Liste
    vim.keymap.set("n", "<C-q>", function()
        local lines = vim.api.nvim_buf_get_lines(bufnr, 0, -1, false)
        -- Nutzt " " statt "r", um eine NEUE Liste im Stack zu erstellen
        vim.fn.setqflist({}, " ", {
            title = title,
            lines = lines,
            efm = "%f:%l:%c:%m,%f"
        })
        vim.api.nvim_win_close(winnr, true)
        vim.cmd("copen")
        
        -- Info über den Quickfix-Stack ausgeben
        local qf_nr = vim.fn.getqflist({nr = 0}).nr
        local qf_total = vim.fn.getqflist({nr = "$"}).nr
        print(string.format("Quickfix-Stack: %d/%d", qf_nr, qf_total))
    end, opts)

    -- q / <Esc> bricht ab
    vim.keymap.set("n", "q", function() vim.api.nvim_win_close(winnr, true) end, opts)
    vim.keymap.set("n", "<Esc>", function() vim.api.nvim_win_close(winnr, true) end, opts)
end

-- Wiki: [[link]] Unterstützung
function M.open_wiki_link()
    local line = vim.api.nvim_get_current_line()
    local col = vim.api.nvim_win_get_cursor(0)[2] + 1
    
    local link = nil
    local start_pos = 1
    while true do
        local s, e, l = line:find("%[%[(.-)%]%]", start_pos)
        if not s then break end
        if col >= s and col <= e then
            link = l
            break
        end
        start_pos = e + 1
    end

    -- Fallback: Erster Link in der Zeile, falls Cursor auf keinem steht
    if not link then
        _, _, link = line:find("%[%[(.-)%]%]")
    end

    if link then
        local wiki_dir = vim.fn.expand("%:p:h")
        local file_path = wiki_dir .. "/" .. link .. ".md"
        -- Verzeichnisse erstellen falls nötig
        local dir = vim.fn.fnamemodify(file_path, ":h")
        if vim.fn.isdirectory(dir) == 0 then
            vim.fn.mkdir(dir, "p")
        end
        vim.cmd("edit " .. file_path)
    else
        print("Kein Wiki-Link gefunden.")
    end
end

-- Findet alle Dateien, die auf die aktuelle Datei verlinken
function M.wiki_backlinks()
    local filename = vim.fn.expand("%:t:r")
    if filename == "" then return end
    
    local pattern = "%[%[" .. filename .. "%]%]"
    local cmd = "rg --vimgrep --smart-case " .. vim.fn.shellescape(pattern)
    local results = vim.fn.systemlist(cmd)
    
    if #results == 0 then
        print("Keine Backlinks gefunden für: " .. filename)
        return
    end

    M.open_picker(results, "Backlinks: " .. filename, function(selected)
        local parts = vim.split(selected, ":")
        if #parts >= 3 then
            vim.cmd("edit " .. parts[1])
            vim.api.nvim_win_set_cursor(0, {tonumber(parts[2]), tonumber(parts[3]) - 1})
        end
    end)
end

-- --- 2. DATEI-SUCHE (Nutzt den Picker) ---
function M.find_files()
  local files = vim.fn.systemlist("fd --type f --strip-cwd-prefix --hidden --exclude .git")
  if #files == 0 then return end
  
  M.open_picker(files, "Dateien finden", function(selected)
    vim.cmd("edit " .. selected)
  end)
end

function M.find_buffers()
    local buffers = vim.api.nvim_list_bufs()
    local items = {}
    for _, bufnr in ipairs(buffers) do
        if vim.api.nvim_buf_is_loaded(bufnr) and vim.bo[bufnr].buflisted then
            local name = vim.api.nvim_buf_get_name(bufnr)
            local short_name = name ~= "" and vim.fn.fnamemodify(name, ":.") or "[No Name]"
            table.insert(items, string.format("%d: %s", bufnr, short_name))
        end
    end

    if #items == 0 then return end

    M.open_picker(items, "Puffer auswählen", function(selected)
        local bufnr = selected:match("^(%d+):")
        if bufnr then
            vim.cmd("buffer " .. bufnr)
        end
    end)
end

-- Projekt-Management via fd
function M.find_projects()
    local cmd = "fd -H -d 4 -t d '^(.git)$' ~ -x dirname"
    local results = vim.fn.systemlist(cmd)

    M.open_picker(results, "Projekte", function(choice)
        if choice then
            vim.cmd("cd " .. choice)
            print("Projekt gewechselt zu: " .. vim.fn.getcwd())
        end
    end)
end

-- --- 3. GREP-SUCHE (Nutzt den Picker) ---
function M.live_grep()
    local pattern = vim.fn.input("Grep > ")
    if pattern == "" then return end
    
    local cmd = "rg --vimgrep --smart-case --hidden --glob '!.git/*' " .. vim.fn.shellescape(pattern)
    local results = vim.fn.systemlist(cmd)
    
    if #results == 0 then
        print("Keine Treffer gefunden.")
        return
    end

    M.open_picker(results, "Grep: " .. pattern, function(selected)
        local parts = vim.split(selected, ":")
        if #parts >= 3 then
            vim.cmd("edit " .. parts[1])
            vim.api.nvim_win_set_cursor(0, {tonumber(parts[2]), tonumber(parts[3]) - 1})
        end
    end)
end

-- --- 4. VERZEICHNIS-SUCHE (Nutzt den Picker) ---
function M.find_directories()
    local dirs = vim.fn.systemlist("fd --type d --strip-cwd-prefix --hidden --exclude .git")
    if #dirs == 0 then return end
    
    M.open_picker(dirs, "Verzeichnis wechseln", function(selected)
        if selected and selected ~= "" then
            vim.cmd("cd " .. selected)
            print("CWD gewechselt zu: " .. vim.fn.getcwd())
        end
    end)
end

-- --- 5. GIT-TOOLS ---

-- Hilfsfunktion zur Anzeige von Git-Output in einem Scratch-Buffer
function M.show_git_output(cmd, title, filetype)
    local output = vim.fn.systemlist(cmd)
    if vim.v.shell_error ~= 0 or #output == 0 then
        print("Fehler beim Ausführen von: " .. cmd)
        return
    end

    local bufnr = vim.api.nvim_create_buf(false, true)
    vim.api.nvim_set_option_value("buftype", "nofile", { buf = bufnr })
    vim.api.nvim_set_option_value("bufhidden", "wipe", { buf = bufnr })
    vim.api.nvim_set_option_value("swapfile", false, { buf = bufnr })
    vim.api.nvim_buf_set_name(bufnr, title or "Git Output")
    vim.api.nvim_buf_set_lines(bufnr, 0, -1, false, output)
    
    if filetype then
        vim.api.nvim_set_option_value("filetype", filetype, { buf = bufnr })
    end

    vim.cmd("vertical botright split")
    local winnr = vim.api.nvim_get_current_win()
    vim.api.nvim_win_set_buf(winnr, bufnr)
    
    local opts = { buffer = bufnr, silent = true }
    vim.keymap.set("n", "q", function() vim.api.nvim_win_close(winnr, true) end, opts)
    vim.keymap.set("n", "<Esc>", function() vim.api.nvim_win_close(winnr, true) end, opts)
end

-- Zeigt das Git-Log für die aktuelle Datei oder das gesamte Projekt
function M.git_log(opts)
    opts = opts or {}
    local file = opts.all and "" or vim.fn.expand("%")
    local is_project = (file == "")
    
    -- Nur innerhalb eines Git-Repos zulassen
    vim.fn.system("git rev-parse --is-inside-work-tree")
    if vim.v.shell_error ~= 0 then
        print("Nicht in einem Git-Repository.")
        return
    end

    local title = is_project and "Git Log (Projekt)" or ("Git Log: " .. file)
    local file_arg = is_project and "" or (" -- " .. vim.fn.shellescape(file))
    local cmd = "git log --pretty=format:'%h %ad | %s [%an]' --date=short" .. file_arg
    
    local results = vim.fn.systemlist(cmd)
    
    if #results == 0 then
        print("Kein Log gefunden.")
        return
    end

    M.open_picker(results, title, function(selected)
        local hash = selected:match("^(%x+)")
        if hash then
            -- Zeige den Commit an (entweder für die ganze Projekt oder nur die Datei)
            local show_cmd = "git show " .. hash .. file_arg
            M.show_git_output(show_cmd, "Commit: " .. hash, "diff")
        end
    end)
end

-- Zeigt das globale Git-Log des Projekts
function M.git_log_project()
    M.git_log({ all = true })
end

-- Zeigt die Historie für den markierten Bereich oder die aktuelle Zeile
function M.git_log_range()
    local file = vim.fn.expand("%")
    if file == "" then return end

    -- Prüfen, ob wir in einem Visual Mode sind
    local mode = vim.fn.mode()
    local start_line, end_line

    if mode:match("[vV]") then
        start_line = vim.fn.line("v")
        end_line = vim.fn.line(".")
        -- Visual Mode verlassen, um Cursor-Positionen zu fixieren
        vim.api.nvim_feedkeys(vim.api.nvim_replace_termcodes("<Esc>", true, false, true), "n", true)
    else
        start_line = vim.api.nvim_win_get_cursor(0)[1]
        end_line = start_line
    end

    -- Sicherstellen, dass start_line <= end_line ist
    if start_line > end_line then
        start_line, end_line = end_line, start_line
    end
    
    -- Nutzt git log -L <start>,<end>:<file>, um Änderungen zu zeigen
    local cmd = "git log -L " .. start_line .. "," .. end_line .. ":" .. vim.fn.shellescape(file)
    M.show_git_output(cmd, "Range History: " .. start_line .. "-" .. end_line, "diff")
end

-- Zeigt Blame-Informationen für die aktuelle Zeile
function M.git_blame_line()
    local file = vim.fn.expand("%")
    local line = vim.api.nvim_win_get_cursor(0)[1]
    if file == "" then return end
    
    local cmd = "git blame -L " .. line .. "," .. line .. " " .. vim.fn.shellescape(file)
    local result = vim.fn.systemlist(cmd)[1]
    if result then
        print(result)
    end
end

-- Zeigt den Git-Status und erlaubt das Diffen von Dateien
function M.git_status()
    local results = vim.fn.systemlist("git status -s")
    if #results == 0 then
        print("Git-Status: Alles sauber (Clean).")
        return
    end
    
    M.open_picker(results, "Git Status (Änderungen)", function(selected)
        -- Das Format von git status -s ist "XY path"
        local file = selected:sub(4)
        M.show_git_output("git diff " .. vim.fn.shellescape(file), "Diff: " .. file, "diff")
    end)
end

-- --- 6. TERMINAL TOGGLE ---

local term_buf = nil
local term_win = nil

function M.toggle_terminal()
    if term_win and vim.api.nvim_win_is_valid(term_win) then
        vim.api.nvim_win_hide(term_win)
        term_win = nil
    else
        vim.cmd("botright split")
        vim.cmd("resize 10")
        term_win = vim.api.nvim_get_current_win()
        
        if term_buf and vim.api.nvim_buf_is_valid(term_buf) then
            vim.api.nvim_win_set_buf(term_win, term_buf)
        else
            vim.cmd("term")
            term_buf = vim.api.nvim_get_current_buf()
            -- Terminal-spezifische Optionen
            vim.wo[term_win].number = false
            vim.wo[term_win].relativenumber = false
            vim.wo[term_win].signcolumn = "no"
        end
        vim.cmd("startinsert")
    end
end

-- --- 7. HILFE & ÜBERSICHT ---

-- Zeigt alle Keymaps mit einer Beschreibung (desc) im Picker an
function M.show_keymaps()
    local global_maps = vim.api.nvim_get_keymap("n")
    local buffer_maps = vim.api.nvim_buf_get_keymap(0, "n")
    local lines = {}

    local function process_maps(maps)
        for _, map in ipairs(maps) do
            if map.desc then
                -- Formatiere: "LHS | Beschreibung"
                -- Wir ersetzen das Leerzeichen (Leader) durch <Leader> für bessere Lesbarkeit
                local lhs = map.lhs:gsub(" ", "<Leader>")
                table.insert(lines, string.format("%-12s │ %s", lhs, map.desc))
            end
        end
    end

    process_maps(global_maps)
    process_maps(buffer_maps)

    table.sort(lines)

    if #lines == 0 then
        print("Keine Keymaps mit Beschreibung gefunden.")
        return
    end

    M.open_picker(lines, "Keymap-Übersicht", function(selected)
        -- Optional: Bei <CR> könnte man die Keymap erklären oder ausführen
    end)
end


return M
