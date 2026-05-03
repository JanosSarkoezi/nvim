-- lua/core/search.lua
local M = {}
local picker = require("core.picker")

function M.find_files()
  local files = vim.fn.systemlist("fd --type f --strip-cwd-prefix --hidden --exclude .git")
  if #files == 0 then return end
  picker.open_picker(files, "Dateien finden", function(selected)
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
    picker.open_picker(items, "Puffer auswählen", function(selected)
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
    picker.open_picker(results, "Projekte", function(choice)
        if choice then
            vim.cmd("cd " .. choice)
            print("Projekt gewechselt zu: " .. vim.fn.getcwd())
        end
    end)
end

function M.live_grep()
    local pattern = vim.fn.input("Grep > ")
    if pattern == "" then return end
    local cmd = "rg --vimgrep --smart-case --hidden --glob '!.git/*' " .. vim.fn.shellescape(pattern)
    local results = vim.fn.systemlist(cmd)
    if #results == 0 then
        print("Keine Treffer gefunden.")
        return
    end
    picker.open_picker(results, "Grep: " .. pattern, function(selected)
        local parts = vim.split(selected, ":")
        if #parts >= 3 then
            vim.cmd("edit " .. parts[1])
            vim.api.nvim_win_set_cursor(0, {tonumber(parts[2]), tonumber(parts[3]) - 1})
        end
    end)
end

function M.find_directories()
    local dirs = vim.fn.systemlist("fd --type d --strip-cwd-prefix --hidden --exclude .git")
    if #dirs == 0 then return end
    picker.open_picker(dirs, "Verzeichnis wechseln", function(selected)
        if selected and selected ~= "" then
            vim.cmd("cd " .. selected)
            print("CWD gewechselt zu: " .. vim.fn.getcwd())
        end
    end)
end

-- Lädt die aktuelle Quickfix-Liste in den Picker
function M.quickfix_to_picker()
    local qflist = vim.fn.getqflist()
    if #qflist == 0 then
        print("Quickfix-Liste ist leer.")
        return
    end
    local items = {}
    for _, entry in ipairs(qflist) do
        local fname = vim.api.nvim_buf_get_name(entry.bufnr)
        local short_name = vim.fn.fnamemodify(fname, ":.")
        -- Format: pfad:zeile:spalte: text
        table.insert(items, string.format("%s:%d:%d: %s", short_name, entry.lnum, entry.col, entry.text))
    end
    picker.open_picker(items, "Quickfix Bearbeiten", function(selected)
        local parts = vim.split(selected, ":")
        if #parts >= 3 then
            vim.cmd("edit " .. parts[1])
            vim.api.nvim_win_set_cursor(0, {tonumber(parts[2]), tonumber(parts[3]) - 1})
        end
    end)
end

return M
