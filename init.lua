require("lazy-bootstrap")
-- Make sure to setup `mapleader` and `maplocalleader` before
-- loading lazy.nvim so that mappings are correct.
-- This is also a good place to setup other settings (vim.opt)
vim.g.mapleader = " "
vim.g.maplocalleader = " "

require("cmd")
require("options")
require("lazy-plugins")

vim.keymap.set('n', '<DOWN>', function () return ':cn<CR>' end, { silent = true, expr = true })
vim.keymap.set('n', '<UP>', function () return ':cp<CR>' end, { silent = true, expr = true })
vim.keymap.set('n', '<RIGHT>', function () return ':cope<CR>' end, { silent = true, expr = true })
vim.keymap.set('n', '<LEFT>', function () return ':cclo<CR>' end, { silent = true, expr = true })
vim.keymap.set('n', '<F1>', function () end, { silent = true, expr = true })
vim.keymap.set('i', '<F1>', function () end, { silent = true, expr = true })

vim.keymap.set('t', '<Esc><Esc>', '<C-\\><C-n>', { desc = 'Exit terminal mode' })

vim.api.nvim_create_user_command("MarkservOpen", function()
  local file = vim.fn.expand("%:p")
  if file == "" then
    print("Keine Datei geöffnet.")
    return
  end

  local dir = vim.fn.fnamemodify(file, ":h")
  local filename = vim.fn.fnamemodify(file, ":t")

  -- Versuche, Port 3999 zu erreichen, um zu prüfen, ob Markserv läuft
  local check_cmd = "curl -s -o /dev/null -w \"%{http_code}\" http://localhost:3999"
  local handle = io.popen(check_cmd)
  local result = handle:read("*a")
  handle:close()

  if result ~= "200" then
    print("Starte Markserv...")
    -- Starte Markserv im Hintergrund
    local cmd = string.format("cd %s && nohup markserv --port 3999 --silent > /dev/null 2>&1 &", vim.fn.shellescape(dir))
    os.execute(cmd)
    -- Gib Markserv Zeit zum Starten
    vim.wait(1000)
  end

  -- Öffne die Datei im Browser
  local open_cmd
  if vim.fn.has("mac") == 1 then
    open_cmd = string.format("open http://localhost:3999/%s", filename)
  elseif vim.fn.has("unix") == 1 then
    open_cmd = string.format("xdg-open http://localhost:3999/%s", filename)
  elseif vim.fn.has("win32") == 1 then
    open_cmd = string.format("start http://localhost:3999/%s", filename)
  else
    print("Unbekanntes Betriebssystem – bitte manuell öffnen.")
    return
  end

  os.execute(open_cmd)
end, {})

vim.keymap.set('n', '<leader>p', ':MarkservOpen<CR>', { desc = "Preview with Markserv" })
