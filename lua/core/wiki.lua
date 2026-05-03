-- lua/core/wiki.lua
local M = {}
local picker = require("core.picker")

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
    picker.open_picker(results, "Backlinks: " .. filename, function(selected)
        local parts = vim.split(selected, ":")
        if #parts >= 3 then
            vim.cmd("edit " .. parts[1])
            vim.api.nvim_win_set_cursor(0, {tonumber(parts[2]), tonumber(parts[3]) - 1})
        end
    end)
end

return M
