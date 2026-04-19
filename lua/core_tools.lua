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
        -- Nutzt ein Errorformat, das sowohl grep (file:line:col:text) als auch einfache Dateilisten versteht
        vim.fn.setqflist({}, "r", {
            title = title,
            lines = lines,
            efm = "%f:%l:%c:%m,%f"
        })
        vim.api.nvim_win_close(winnr, true)
        vim.cmd("copen")
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

return M
