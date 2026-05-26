-- lua/core/marks.lua
local M = {}
local picker = require("core.picker")

-- Speicher für die Rotation der automatischen Marks (Zähler pro Buffer / Global)
local last_used_local_idx = 0
local last_used_global_idx = 0

-- Setzt ein Mark automatisch im nächsten freien oder rotierenden Register
function M.set_mark_auto(is_global)
    local bufnr = vim.api.nvim_get_current_buf()
    local list = is_global and {'A', 'B', 'C', 'D', 'E'} or {'a', 'b', 'c', 'd', 'e'}

    -- Prüfe, welche Marks aktuell belegt sind
    local set_marks = {}
    local mark_list = is_global and vim.fn.getmarklist() or vim.fn.getmarklist(bufnr)
    for _, m in ipairs(mark_list) do
        local char = m.mark:sub(2)
        set_marks[char] = true
    end

    local target = nil

    -- 1. Suche ein Mark, das nicht belegt ist
    for _, m in ipairs(list) do
        if not set_marks[m] then
            target = m
            break
        end
    end

    -- 2. Wenn alle belegt sind, rotiere sauber durch (Round-Robin)
    if not target then
        if is_global then
            last_used_global_idx = (last_used_global_idx % #list) + 1
            target = list[last_used_global_idx]
        else
            last_used_local_idx = (last_used_local_idx % #list) + 1
            target = list[last_used_local_idx]
        end
    end

    vim.cmd("normal! m" .. target)
    local type_str = is_global and "Globales" or "Lokales"
    print(string.format("%s Mark '%s' gesetzt.", type_str, target))
end

-- Zeigt die Marks a-e und A-E im Picker an
function M.show_marks()
    local raw_items = {}
    local origin_bufnr = vim.api.nvim_get_current_buf()

    local function add_marks(mark_list, targets, is_local)
        for _, m in ipairs(mark_list) do
            local clean_mark = m.mark:sub(2)
            if targets[clean_mark] then
                local lnum = m.pos[2]
                local fname = is_local and "[Lokal]" or (m.file and vim.fn.fnamemodify(m.file, ":.") or "[Unbekannt]")

                local content = ""
                local target_buf = is_local and origin_bufnr or vim.fn.bufnr(m.file)

                if target_buf ~= -1 and vim.api.nvim_buf_is_loaded(target_buf) then
                    content = vim.api.nvim_buf_get_lines(target_buf, lnum - 1, lnum, false)[1] or ""
                elseif m.file and vim.fn.filereadable(m.file) == 1 then
                    -- Fallback: Zeile direkt aus der Datei lesen, wenn Puffer nicht geladen ist
                    local lines = vim.fn.readfile(m.file, "", lnum)
                    content = lines[lnum] or "[Leere Zeile]"
                else
                    content = "[Datei nicht lesbar / nicht geladen]"
                end

                table.insert(raw_items, {
                    mark = clean_mark,
                    fname = fname,
                    lnum = lnum,
                    content = vim.trim(content),
                    is_local = is_local
                })
            end
        end
    end

    -- Lokale und globale Markierungen holen
    add_marks(vim.fn.getmarklist(origin_bufnr), { a=true, b=true, c=true, d=true, e=true }, true)
    add_marks(vim.fn.getmarklist(), { A=true, B=true, C=true, D=true, E=true }, false)

    if #raw_items == 0 then
        print("Keine Markierungen (a-e, A-E) gesetzt.")
        return
    end

    -- VOR der Formatierung sauber nach Relevanz sortieren (Lokale zuerst, dann Alphabetisch)
    table.sort(raw_items, function(a, b)
        if a.is_local and not b.is_local then return true end
        if not a.is_local and b.is_local then return false end
        return a.mark < b.mark
    end)

    -- Dynamische Breite berechnen
    local max_fname_len = 20
    for _, item in ipairs(raw_items) do
        max_fname_len = math.max(max_fname_len, #item.fname)
    end
    local fname_width = math.min(max_fname_len, 50)

    -- UI-Strings bauen
    local items = {}
    for _, item in ipairs(raw_items) do
        local display_fname = item.fname
        if #display_fname > fname_width then
            display_fname = "…" .. display_fname:sub(-(fname_width - 1))
        end

        local max_content_len = 50
        local content = item.content
        if #content > max_content_len then
            content = content:sub(1, max_content_len - 3) .. "..."
        end

        local format_string = string.format(" %%s │ %%-%ds │ %%4d │ %%s", fname_width)
        table.insert(items, string.format(format_string, item.mark, display_fname, item.lnum, content))
    end

    local title = "Mark Manager (dd=Delete, CR=Jump)"
    picker.open_picker(items, title, function(selected)
        local mark_name = selected:match("%s*(%a)")
        if mark_name then
            if mark_name:match("%u") then
                vim.cmd("normal! '" .. mark_name)
            else
                -- Sicherstellen, dass wir im richtigen Buffer springen
                if vim.api.nvim_buf_is_valid(origin_bufnr) then
                    vim.api.nvim_set_current_buf(origin_bufnr)
                end
                vim.cmd("normal! '" .. mark_name)
            end
        end
    end, {
        dd = function(selected, dd_bufnr, dd_winnr)
            local mark_name = selected:match("%s*(%a)")
            if mark_name then
                if mark_name:match("%u") then
                    vim.api.nvim_del_mark(mark_name)
                else
                    vim.api.nvim_buf_del_mark(origin_bufnr, mark_name)
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
    }, true)
end

return M
