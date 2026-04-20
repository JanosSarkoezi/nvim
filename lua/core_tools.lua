-- lua/core_tools.lua
-- Wiki, Projekt-Management und Buffer-basierte Auswahl

local M = {}

-- Zentrale Funktion für Puffer-basierte Auswahl (M.open_picker)
function M.open_picker(items, title, callback)
    -- Neuen Scratch-Puffer erstellen
    local bufnr = vim.api.nvim_create_buf(false, true)
    vim.api.nvim_buf_set_option(bufnr, "buftype", "nofile")
    vim.api.nvim_buf_set_option(bufnr, "bufhidden", "wipe")
    vim.api.nvim_buf_set_option(bufnr, "swapfile", false)
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
    local col = vim.api.nvim_win_get_cursor(0)[2]
    -- Suche nach [[link]]
    local start_idx, end_idx, link = line:find("%[%[(.-)%]%]")
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

-- --- 2. DATEI-SUCHE (Nutzt den Picker) ---
function M.find_files()
  local files = vim.fn.systemlist("fd --type f --strip-cwd-prefix --hidden --exclude .git")
  if #files == 0 then return end
  
  M.open_picker(files, "Dateien finden", function(selected)
    vim.cmd("edit " .. selected)
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
    if #output == 0 then
        print("Keine Ausgabe für: " .. cmd)
        return
    end

    local bufnr = vim.api.nvim_create_buf(false, true)
    vim.api.nvim_buf_set_option(bufnr, "buftype", "nofile")
    vim.api.nvim_buf_set_option(bufnr, "bufhidden", "wipe")
    vim.api.nvim_buf_set_option(bufnr, "swapfile", false)
    vim.api.nvim_buf_set_name(bufnr, title or "Git Output")
    vim.api.nvim_buf_set_lines(bufnr, 0, -1, false, output)
    
    if filetype then
        vim.api.nvim_buf_set_option(bufnr, "filetype", filetype)
    end

    vim.cmd("vertical botright split")
    local winnr = vim.api.nvim_get_current_win()
    vim.api.nvim_win_set_buf(winnr, bufnr)
    
    local opts = { buffer = bufnr, silent = true }
    vim.keymap.set("n", "q", function() vim.api.nvim_win_close(winnr, true) end, opts)
    vim.keymap.set("n", "<Esc>", function() vim.api.nvim_win_close(winnr, true) end, opts)
end

-- Zeigt das Git-Log für die aktuelle Datei
function M.git_log()
    local file = vim.fn.expand("%")
    if file == "" then return end
    -- Nur Dateien innerhalb des Git-Repos zulassen
    if vim.fn.system("git rev-parse --is-inside-work-tree"):match("false") then
        print("Nicht in einem Git-Repository.")
        return
    end

    local cmd = "git log --pretty=format:'%h %ad | %s [%an]' --date=short -- " .. vim.fn.shellescape(file)
    local results = vim.fn.systemlist(cmd)
    
    if #results == 0 then
        print("Kein Log für diese Datei gefunden.")
        return
    end

    M.open_picker(results, "Git Log: " .. file, function(selected)
        local hash = selected:match("^(%x+)")
        if hash then
            M.show_git_output("git show " .. hash .. " -- " .. vim.fn.shellescape(file), "Commit: " .. hash, "diff")
        end
    end)
end

-- Zeigt die Historie für die aktuelle Zeile
function M.git_log_line()
    local file = vim.fn.expand("%")
    local line = vim.api.nvim_win_get_cursor(0)[1]
    if file == "" then return end
    
    -- Nutzt git log -L, um Änderungen an dieser Zeile zu zeigen
    local cmd = "git log -L " .. line .. "," .. line .. ":" .. vim.fn.shellescape(file)
    M.show_git_output(cmd, "Line History: " .. line, "diff")
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

-- --- 6. HILFE & ÜBERSICHT ---

-- Zeigt alle Keymaps mit einer Beschreibung (desc) im Picker an
function M.show_keymaps()
    local maps = vim.api.nvim_get_keymap("n")
    local lines = {}
    
    for _, map in ipairs(maps) do
        if map.desc then
            -- Formatiere: "LHS | Beschreibung"
            -- Wir ersetzen das Leerzeichen (Leader) durch <Leader> für bessere Lesbarkeit
            local lhs = map.lhs:gsub(" ", "<Leader>")
            table.insert(lines, string.format("%-12s │ %s", lhs, map.desc))
        end
    end
    
    table.sort(lines)
    
    if #lines == 0 then
        print("Keine Keymaps mit Beschreibung gefunden.")
        return
    end

    M.open_picker(lines, "Keymap-Übersicht", function(selected)
        -- Optional: Bei <CR> könnte man die Keymap erklären oder ausführen
        -- Fürs Erste reicht die Übersicht
    end)
end

return M
