-- lua/core/marks.lua
local M = {}
local picker = require("core.picker")

-- Globaler State für globale Marks (A-E)
local global_mark_state = {
    order = {'A', 'B', 'C', 'D', 'E'},
    pinned = {}
}
local global_initialized = false

-- Hilfsfunktion: Holt den State (Order & Pinned) für den jeweiligen Kontext
local function get_state(is_global, bufnr)
    if is_global then
        if not global_initialized then
            -- Initialer Sync: Bereits gesetzte Marks ans Ende der Liste schieben (als "kürzlich verwendet")
            local set_marks = {}
            for _, m in ipairs(vim.fn.getmarklist()) do
                local char = m.mark:sub(2)
                if char:match("%u") then set_marks[char] = true end
            end
            
            local new_order = {}
            local existing = {}
            for _, m in ipairs(global_mark_state.order) do
                if set_marks[m] then
                    table.insert(existing, m)
                else
                    table.insert(new_order, m)
                end
            end
            for _, m in ipairs(existing) do table.insert(new_order, m) end
            global_mark_state.order = new_order
            global_initialized = true
        end
        return global_mark_state.order, global_mark_state.pinned
    else
        local b = bufnr or vim.api.nvim_get_current_buf()
        -- Initialisiere Puffer-lokalen State falls nicht vorhanden
        if not vim.b[b].mark_manager_order then
            vim.b[b].mark_manager_order = {'a', 'b', 'c', 'd', 'e'}
            vim.b[b].mark_manager_pinned = vim.b[b].mark_manager_pinned or {}
        end
        return vim.b[b].mark_manager_order, vim.b[b].mark_manager_pinned
    end
end

-- Hilfsfunktion: Schiebt ein Register ans Ende der Liste (als "neuestes")
local function touch_mark(name, is_global, bufnr)
    local actual_bufnr = bufnr or vim.api.nvim_get_current_buf()
    local list, _ = get_state(is_global, actual_bufnr)
    for i, m in ipairs(list) do
        if m == name then
            table.remove(list, i)
            table.insert(list, m)
            -- Zurückschreiben in vim.b falls lokal
            if not is_global then
                vim.b[actual_bufnr].mark_manager_order = list
            end
            break
        end
    end
end

-- Setzt ein Mark automatisch im nächsten freien/ältesten un-gepinnten Register
function M.set_mark_auto(is_global)
    local bufnr = vim.api.nvim_get_current_buf()
    local list, pinned = get_state(is_global, bufnr)
    
    -- Prüfe, welche Marks aktuell belegt sind
    local set_marks = {}
    local mark_list = is_global and vim.fn.getmarklist() or vim.fn.getmarklist(bufnr)
    for _, m in ipairs(mark_list) do
        local char = m.mark:sub(2)
        set_marks[char] = true
    end

    local target = nil
    
    -- 1. Suche ein Mark, das NICHT belegt und NICHT gepinnt ist
    for _, m in ipairs(list) do
        if not set_marks[m] and not pinned[m] then
            target = m
            break
        end
    end

    -- 2. Falls alle belegt, nimm das älteste (vorne in der Liste), das nicht gepinnt ist
    if not target then
        for _, m in ipairs(list) do
            if not pinned[m] then
                target = m
                break
            end
        end
    end

    if not target then
        print("Alle Marks sind gepinnt! Bitte eines entpinnen.")
        return
    end

    vim.cmd("normal! m" .. target)
    touch_mark(target, is_global, bufnr)
    local type_str = is_global and "Globales" or "Lokales"
    print(string.format("%s Mark '%s' gesetzt.", type_str, target))
end

-- Toggle Pin-Status
function M.toggle_mark_pin(mark_name, bufnr)
    if not mark_name or mark_name == "" then return end
    local is_global = mark_name:match("%u") ~= nil
    local _, pinned = get_state(is_global, bufnr)
    
    pinned[mark_name] = not pinned[mark_name]
    
    -- Zurückschreiben falls lokal (vim.b braucht explizite Zuweisung für Änderungen in Tables)
    if not is_global then
        vim.b[bufnr or 0].mark_manager_pinned = pinned
    end
    
    local status = pinned[mark_name] and "gepinnt" or "entpinnt"
    print(string.format("Mark '%s' %s.", mark_name, status))
end

-- Zeigt die Marks a-e und A-E im Picker an
function M.show_marks(target_bufnr)
    local items = {}
    local origin_bufnr = target_bufnr or vim.api.nvim_get_current_buf()
    
    local function add_marks(mark_list, targets, is_local)
        local _, pinned = get_state(not is_local, origin_bufnr)
        for _, m in ipairs(mark_list) do
            local clean_mark = m.mark:sub(2)
            if targets[clean_mark] then
                local lnum = m.pos[2]
                local is_pinned = pinned[clean_mark]
                local pin_str = is_pinned and "[L]" or "[ ]"
                local fname = is_local and "[Lokal]" or (m.file and vim.fn.fnamemodify(m.file, ":.") or "[Unbekannt]")
                
                -- Visuelle Formatierung des Dateinamens (feste Breite 25, Kürzung von links)
                local fname_width = 25
                local display_fname = fname
                if #display_fname > fname_width then
                    display_fname = "…" .. display_fname:sub(-(fname_width - 1))
                end

                local content = ""
                local target_buf = is_local and origin_bufnr or vim.fn.bufnr(m.file)
                
                if target_buf ~= -1 and vim.api.nvim_buf_is_loaded(target_buf) then
                    content = vim.api.nvim_buf_get_lines(target_buf, lnum - 1, lnum, false)[1] or ""
                else
                    content = "[Puffer nicht geladen]"
                end
                table.insert(items, string.format("%s %s │ %-25s │ %4d │ %s", clean_mark, pin_str, display_fname, lnum, vim.trim(content)))
            end
        end
    end

    add_marks(vim.fn.getmarklist(origin_bufnr), { a=true, b=true, c=true, d=true, e=true }, true)
    add_marks(vim.fn.getmarklist(), { A=true, B=true, C=true, D=true, E=true }, false)

    if #items == 0 then
        print("Keine Marks (a-e, A-E) gesetzt. Nutze <Leader>m oder <Leader>n.")
        return
    end

    table.sort(items, function(a, b)
        local ma = a:sub(1,1)
        local mb = b:sub(1,1)
        if ma:match("%l") and mb:match("%u") then return true end
        if ma:match("%u") and mb:match("%l") then return false end
        return ma < mb
    end)

    local title = "Mark Manager (p=Pin/Unpin, dd=Delete, CR=Jump)"
    picker.open_picker(items, title, function(selected)
        local mark_name = selected:match("^(.)")
        if mark_name then
            local is_global = mark_name:match("%u") ~= nil
            if is_global then
                vim.cmd("normal! '" .. mark_name)
            else
                vim.api.nvim_set_current_buf(origin_bufnr)
                vim.cmd("normal! '" .. mark_name)
            end
            touch_mark(mark_name, is_global, origin_bufnr)
        end
    end, {
        p = function(selected, p_bufnr)
            local mark_name = selected:match("^(.)")
            M.toggle_mark_pin(mark_name, origin_bufnr)
            local cursor = vim.api.nvim_win_get_cursor(0)
            vim.api.nvim_win_close(0, true)
            M.show_marks(origin_bufnr)
            pcall(vim.api.nvim_win_set_cursor, 0, cursor)
        end,
        dd = function(selected, dd_bufnr, dd_winnr)
            local mark_name = selected:match("^(.)")
            if mark_name then
                local is_global = mark_name:match("%u") ~= nil
                local list, pinned = get_state(is_global, origin_bufnr)

                if is_global then
                    vim.api.nvim_del_mark(mark_name)
                else
                    vim.api.nvim_buf_del_mark(origin_bufnr, mark_name)
                end

                pinned[mark_name] = nil
                -- Zurückschreiben falls lokal
                if not is_global then
                    vim.b[origin_bufnr].mark_manager_pinned = pinned
                end

                for i, m in ipairs(list) do
                    if m == mark_name then
                        table.remove(list, i)
                        table.insert(list, 1, m)
                        if not is_global then
                            vim.b[origin_bufnr].mark_manager_order = list
                        end
                        break
                    end
                end

                local cursor_line = vim.api.nvim_win_get_cursor(dd_winnr)[1]
                vim.api.nvim_buf_set_lines(dd_bufnr, cursor_line - 1, cursor_line, false, {})
                print(string.format("Mark '%s' gelöscht.", mark_name))
                if vim.api.nvim_buf_line_count(dd_bufnr) == 1 and 
                   vim.api.nvim_buf_get_lines(dd_bufnr, 0, 1, false)[1] == "" then
                    vim.api.nvim_win_close(dd_winnr, true)
                end
            end
        end
    })
end

return M
