-- lua/core_tools.lua
-- Zentrales Einstiegsmodul, das die spezialisierten Core-Module lädt
-- Dies erhält die Kompatibilität mit bestehenden Keymaps.

local M = {}

-- Module laden
local picker = require("core.picker")
local wiki   = require("core.wiki")
local search = require("core.search")
local git    = require("core.git")
local marks  = require("core.marks")
local misc   = require("core.misc")

-- Picker (Herzstück)
M.open_picker = picker.open_picker

-- Wiki
M.open_wiki_link = wiki.open_wiki_link
M.wiki_backlinks = wiki.wiki_backlinks

-- Suche & Navigation
M.find_files         = search.find_files
M.find_buffers       = search.find_buffers
M.find_projects      = search.find_projects
M.live_grep          = search.live_grep
M.find_directories   = search.find_directories
M.quickfix_to_picker = search.quickfix_to_picker

-- Git Tools
M.show_git_output   = git.show_git_output
M.git_log           = git.git_log
M.git_log_project   = git.git_log_project
M.git_log_range     = git.git_log_range
M.git_blame_line    = git.git_blame_line
M.git_status        = git.git_status
M.git_branches      = git.git_branches
M.git_stash         = git.git_stash

-- Mark Manager
M.set_mark_auto      = marks.set_mark_auto
M.toggle_mark_pin    = marks.toggle_mark_pin
M.show_marks         = marks.show_marks

-- Misc / Hilfe
M.toggle_terminal    = misc.toggle_terminal
M.show_keymaps       = misc.show_keymaps

return M
