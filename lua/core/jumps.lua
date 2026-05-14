-- lua/core/jumps.lua
local M = {}
local picker = require("core.picker")

-- Zeigt die Jumplist (Sprungliste) im Picker an
function M.show_jumps()
    local jumplist_raw = vim.fn.getjumplist()
    local jumps = jumplist_raw[1]
    local current_idx = jumplist_raw[2] -- 0-basierter Index des aktuellen Standorts
    
    if #jumps == 0 then
        print("Jumplist ist leer.")
        return
    end

    local items = {}
    local raw_data = {}

    -- Wir gehen die Liste rückwärts durch (neueste Sprünge oben)
    -- Da die Jumplist oft Duplikate enthält, filtern wir sie hier optional
    for i = #jumps, 1, -1 do
        local jump = jumps[i]
        local bufnr = jump.bufnr
        local lnum = jump.lnum
        local col = jump.col
        
        if vim.api.nvim_buf_is_valid(bufnr) then
            local fname = vim.api.nvim_buf_get_name(bufnr)
            local short_name = fname ~= "" and vim.fn.fnamemodify(fname, ":.") or "[Kein Name]"
            
            -- Vorschau der Zeile holen
            local content = ""
            if vim.api.nvim_buf_is_loaded(bufnr) then
                content = vim.api.nvim_buf_get_lines(bufnr, lnum - 1, lnum, false)[1] or ""
            else
                content = "[Puffer nicht geladen]"
            end
            content = vim.trim(content)

            -- Markierung für die aktuelle Position in der Liste
            local current_mark = (i - 1 == current_idx) and ">" or " "

            table.insert(raw_data, {
                idx = i - 1,
                mark = current_mark,
                fname = short_name,
                lnum = lnum,
                col = col,
                content = content
            })
        end
    end

    -- Formatierung für den Picker
    for _, d in ipairs(raw_data) do
        -- Format: > [Index] Dateiname:Zeile │ Vorschau
        table.insert(items, string.format(" %s [%2d] %s:%d │ %s", 
            d.mark, d.idx, d.fname, d.lnum, d.content))
    end

    picker.open_picker(items, "Jumplist (Neu -> Alt)", function(selected)
        -- Extrahiere Index oder direkt Pfad/Zeile
        -- Da wir die Liste umgedreht haben, ist das Mapping zum Original-Index wichtig
        local idx_str = selected:match("%[(%s*%d+)%]")
        if idx_str then
            local target_idx = tonumber(idx_str)
            -- Wir nutzen den nativen Jump-Befehl, um die interne Liste synchron zu halten
            -- "count<C-o>" oder ähnliches ist schwer, daher setzen wir den Cursor direkt
            -- und simulieren einen Sprung, damit die Jumplist-Position aktualisiert wird.
            local target_jump = jumps[target_idx + 1]
            if target_jump then
                vim.cmd("buffer " .. target_jump.bufnr)
                vim.api.nvim_win_set_cursor(0, {target_jump.lnum, target_jump.col})
            end
        end
    end)
end

return M
