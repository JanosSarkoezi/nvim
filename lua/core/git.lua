-- lua/core/git.lua
local M = {}
local picker = require("core.picker")

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
    picker.open_picker(items, "Git Status (s=Stage, u=Unstage, CR=Diff)", function(selected)
        local file = selected:sub(4)
        M.show_git_output("git diff " .. vim.fn.shellescape(file), "Diff: " .. file, "diff")
    end, {
        s = function(selected, bufnr)
            local file = selected:sub(4)
            vim.fn.system("git add " .. vim.fn.shellescape(file))
            refresh_picker(bufnr)
        end,
        u = function(selected, bufnr)
            local file = selected:sub(4)
            vim.fn.system("git restore --staged " .. vim.fn.shellescape(file))
            refresh_picker(bufnr)
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
