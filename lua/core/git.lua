-- lua/core/git.lua
local M = {}
local picker = require("core.picker")

-- Native Gutter-Signs Initialisierung
function M.setup_gutter()
    vim.fn.sign_define("GitAdd", { text = "+", texthl = "GitSignsAdd" })
    vim.fn.sign_define("GitChange", { text = "│", texthl = "GitSignsChange" })
    vim.fn.sign_define("GitDelete", { text = "_", texthl = "GitSignsDelete" })

    -- Standard-Highlights falls nicht vom Theme gesetzt
    vim.cmd([[
        highlight default GitSignsAdd guifg=#b8bb26
        highlight default GitSignsChange guifg=#fabd2f
        highlight default GitSignsDelete guifg=#fb4934
    ]])

    local group = vim.api.nvim_create_augroup("GitGutter", { clear = true })
    vim.api.nvim_create_autocmd({ "BufReadPost", "BufWritePost", "FocusGained" }, {
        group = group,
        callback = function() M.update_gutter_signs() end,
    })
end

-- Aktualisiert die Signs in der Gutter basierend auf git diff
function M.update_gutter_signs()
    local bufnr = vim.api.nvim_get_current_buf()
    local file = vim.api.nvim_buf_get_name(bufnr)
    if file == "" or vim.bo[bufnr].buftype ~= "" then return end

    -- Prüfen ob im Git-Repo
    vim.fn.system("git rev-parse --is-inside-work-tree")
    if vim.v.shell_error ~= 0 then return end

    -- Bestehende Signs löschen
    vim.fn.sign_unplace("GitGutter", { buffer = bufnr })

    local cmd = "git diff -U0 --no-color -- " .. vim.fn.shellescape(file)
    local diff = vim.fn.systemlist(cmd)

    for _, line in ipairs(diff) do
        local old_start, old_count, new_start, new_count = line:match("^@@ %-(%d+),?(%d*) %+(%d+),?(%d*) @@")
        if old_start then
            old_start = tonumber(old_start)
            old_count = tonumber(old_count == "" and 1 or old_count)
            new_start = tonumber(new_start)
            new_count = tonumber(new_count == "" and 1 or new_count)

            if new_count > 0 then
                local name = old_count > 0 and "GitChange" or "GitAdd"
                for i = 0, new_count - 1 do
                    vim.fn.sign_place(0, "GitGutter", name, bufnr, { lnum = new_start + i, priority = 10 })
                end
            elseif old_count > 0 then
                -- Deletion: Sign an die Position setzen, wo gelöscht wurde
                local lnum = math.max(1, new_start)
                vim.fn.sign_place(0, "GitGutter", "GitDelete", bufnr, { lnum = lnum, priority = 10 })
            end
        end
    end
end

-- Springt von einer Zeile im Diff zur entsprechenden Stelle in der Quelldatei
function M.diff_jump()
    local line = vim.api.nvim_get_current_line()
    if line:match("^%-") then
        print("Sprung nicht möglich: Zeile ist gelöscht.")
        return
    end

    local bufnr = vim.api.nvim_get_current_buf()
    local cursor_row = vim.api.nvim_win_get_cursor(0)[1]

    local file_path = nil
    local hunk_start_line = nil
    local hunk_buffer_row = nil

    -- Rückwärts suchen nach Datei und Hunk
    for i = cursor_row, 1, -1 do
        local l = vim.api.nvim_buf_get_lines(bufnr, i-1, i, false)[1]
        if not l then break end -- Absicherung gegen leere Zeilen

        if not file_path then
            file_path = l:match("^%+%+%+ b/(.*)")
        end
        if not hunk_start_line then
            local _, new_start = l:match("^@@ %-(%d+),?%d* %+(%d+),?%d* @@")
            if new_start then
                hunk_start_line = tonumber(new_start)
                hunk_buffer_row = i
            end
        end
        if file_path and hunk_start_line then
            break
        end
    end

    -- Fallback-Logik für Dateipfad
    if not file_path or not hunk_start_line then
        local bufname = vim.api.nvim_buf_get_name(bufnr)
        file_path = file_path or bufname:match("Diff: (.*)")

        if not file_path then
            file_path = bufname:match("([^/]+)$")
        end
    end

    -- Absolute Absicherung vor dem Sprung
    if not file_path or not hunk_start_line or not hunk_buffer_row then
        print("Fehler: Datei oder Hunk-Startzeile konnte nicht lokalisiert werden.")
        return
    end

    -- Zeile im File berechnen
    local target_line = hunk_start_line
    for i = hunk_buffer_row + 1, cursor_row - 1 do
        local l = vim.api.nvim_buf_get_lines(bufnr, i-1, i, false)[1]
        if l and not l:match("^%-") then
            target_line = target_line + 1
        end
    end

    local current_win = vim.api.nvim_get_current_win()
    local target_win = nil

    -- 1. Prüfen, ob die Datei bereits in einem editierbaren Fenster offen ist
    for _, win in ipairs(vim.api.nvim_list_wins()) do
        local buf = vim.api.nvim_win_get_buf(win)
        local name = vim.api.nvim_buf_get_name(buf)
        if name:find(file_path, 1, true) and not vim.wo[win].winfixbuf then
            target_win = win
            break
        end
    end

    -- 2. Suchen nach dem Fenster LINKS vom aktuellen Fenster
    if not target_win then
        vim.cmd("wincmd h")
        local left_win = vim.api.nvim_get_current_win()
        if left_win ~= current_win and not vim.wo[left_win].winfixbuf then
            target_win = left_win
        else
            -- Zurücksetzen, falls das linke Fenster nicht nutzbar war
            vim.api.nvim_set_current_win(current_win)
        end
    end

    -- 3. Falls kein Fenster gefunden wurde: Neues erstellen
    if not target_win then
        vim.cmd("leftabove vertical split")
        target_win = vim.api.nvim_get_current_win()
    end

    -- 4. Sprung ausführen
    vim.api.nvim_set_current_win(target_win)
    vim.wo[target_win].winfixbuf = false
    vim.cmd("edit " .. vim.fn.fnameescape(file_path))

    -- Sicherstellen, dass wir nicht über das Dateiende hinausspringen
    local total_lines = vim.api.nvim_buf_line_count(0)
    target_line = math.min(target_line, total_lines)

    vim.api.nvim_win_set_cursor(0, { target_line, 0 })
end

-- Hilfsfunktion zur Anzeige von Git-Output in einem Scratch-Buffer
function M.show_git_output(cmd, title, filetype)
    local base_name = title or "Git Output"

    -- Prüfen auf Duplikate
    local existing_bufnr = vim.fn.bufnr(base_name)
    if existing_bufnr ~= -1 and vim.api.nvim_buf_is_valid(existing_bufnr) then
        local wins = vim.fn.win_findbuf(existing_bufnr)
        if #wins > 0 then
            vim.api.nvim_set_current_win(wins[1])
            return
        end
        vim.api.nvim_buf_delete(existing_bufnr, { force = true })
    end

    local output = vim.fn.systemlist(cmd)
    if vim.v.shell_error ~= 0 or #output == 0 then
        print("Fehler beim Ausführen von: " .. cmd)
        return
    end
    local bufnr = vim.api.nvim_create_buf(false, true)
    vim.api.nvim_set_option_value("buftype", "nofile", { buf = bufnr })
    vim.api.nvim_set_option_value("bufhidden", "wipe", { buf = bufnr })
    vim.api.nvim_set_option_value("swapfile", false, { buf = bufnr })
    vim.api.nvim_buf_set_name(bufnr, base_name)
    vim.api.nvim_buf_set_lines(bufnr, 0, -1, false, output)
    if filetype then
        vim.api.nvim_set_option_value("filetype", filetype, { buf = bufnr })
    end
    vim.cmd("vertical botright split")
    local winnr = vim.api.nvim_get_current_win()
    vim.api.nvim_win_set_buf(winnr, bufnr)

    -- Fenster auf diesen Puffer fixieren
    vim.wo[winnr].winfixbuf = true
    local opts = { buffer = bufnr, silent = true }

    local function smart_close()
        if #vim.api.nvim_list_wins() > 1 then
            -- pcall fängt ab, falls das Fenster bereits anderweitig geschlossen wurde
            pcall(vim.api.nvim_win_close, 0, true)
        else
            -- Wenn es das letzte Fenster ist, laden wir einfach einen leeren Buffer
            -- ZUERST winfixbuf deaktivieren, sonst erlaubt Vim den Buffer-Wechsel nicht
            vim.wo[0].winfixbuf = false
            local empty_buf = vim.api.nvim_create_buf(false, true)
            vim.api.nvim_win_set_buf(0, empty_buf)
        end
    end

    vim.keymap.set("n", "q", smart_close, opts)
    vim.keymap.set("n", "<Esc>", smart_close, opts)

    if filetype == "diff" then
        vim.keymap.set("n", "<CR>", function() M.diff_jump() end, opts)
    end
end

-- Zeigt das Git-Log für die aktuelle Datei oder das gesamte Projekt
function M.git_log(opts)
    opts = opts or {}
    local file
    if opts.all then
        file = ""
    else
        file = opts.file or vim.fn.expand("%")
    end

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
    picker.open_picker(results, title, function(selected)
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

-- Extrahiert den Dateipfad aus einer "git status --short"-Zeile.
-- Berücksichtigt Renames ("old -> new") und von Git gequotete Pfade.
local function parse_status_path(line)
    local path = line:sub(4)
    local renamed = path:match(" -> (.+)$")
    if renamed then path = renamed end
    if path:sub(1, 1) == '"' and path:sub(-1) == '"' then
        path = path:sub(2, -2):gsub("\\(.)", "%1")
    end
    return path
end

-- Zeigt den Git-Status und erlaubt das Diffen, Staging und Unstaging
function M.git_status()
    local function get_status_items()
        return vim.fn.systemlist("git status -s")
    end
    local items = get_status_items()
    if #items == 0 then
        print("Git-Status: Alles sauber (Clean).")
        return
    end
    local function refresh_picker(bufnr)
        local new_items = get_status_items()
        vim.api.nvim_buf_set_lines(bufnr, 0, -1, false, new_items)
        if #new_items == 0 then
            print("Git-Status: Alles sauber.")
        end
    end
    picker.open_picker(items, "Git Status (s=Stage, u=Unstage, l=Log, CR=Diff)", function(selected)
        local file = parse_status_path(selected)
        M.show_git_output("git diff " .. vim.fn.shellescape(file), "Diff: " .. file, "diff")
    end, {
        s = function(selected, bufnr)
            local file = parse_status_path(selected)
            vim.fn.system("git add " .. vim.fn.shellescape(file))
            refresh_picker(bufnr)
        end,
        u = function(selected, bufnr)
            local file = parse_status_path(selected)
            vim.fn.system("git restore --staged " .. vim.fn.shellescape(file))
            refresh_picker(bufnr)
        end,
        l = function(selected)
            local file = parse_status_path(selected)
            M.git_log({ file = file })
        end
    })
end

-- Zeigt alle Git-Branches und erlaubt den Wechsel
function M.git_branches()
    local branches = vim.fn.systemlist("git branch --format='%(refname:short)'")
    picker.open_picker(branches, "Git Branches", function(selected)
        local output = vim.fn.system("git checkout " .. vim.fn.shellescape(selected))
        print(output)
    end)
end

-- Zeigt Git-Stashes und erlaubt das Anwenden oder Löschen
function M.git_stash()
    local stashes = vim.fn.systemlist("git stash list")
    if #stashes == 0 then
        print("Keine Stashes vorhanden.")
        return
    end
    picker.open_picker(stashes, "Git Stash (CR=Apply, d=Drop)", function(selected)
        local id = selected:match("^(stash@{%d+})")
        if id then
            local output = vim.fn.system("git stash apply " .. id)
            print(output)
        end
    end, {
        d = function(selected, bufnr)
            local id = selected:match("^(stash@{%d+})")
            if id then
                vim.fn.system("git stash drop " .. id)
                local new_stashes = vim.fn.systemlist("git stash list")
                vim.api.nvim_buf_set_lines(bufnr, 0, -1, false, new_stashes)
            end
        end
    })
end

return M
