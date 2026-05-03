-- lua/core/picker.lua
local M = {}

-- Zentrale Funktion für Puffer-basierte Auswahl (M.open_picker)
function M.open_picker(items, title, callback, extra_mappings)
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
    -- Extra Mappings (falls vorhanden)
    if extra_mappings then
        for key, func in pairs(extra_mappings) do
            vim.keymap.set("n", key, function()
                local cursor_line = vim.api.nvim_win_get_cursor(winnr)[1]
                local selected_item = vim.api.nvim_buf_get_lines(bufnr, cursor_line - 1, cursor_line, false)[1]
                func(selected_item, bufnr, winnr)
            end, opts)
        end
    end
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

return M
