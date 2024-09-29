return {
  {
    "ibhagwan/fzf-lua",
    init = function()
      vim.keymap.set("n", "<leader>sn", function() require('fzf-lua').files({ cwd='~/.config/nvim' }) end)
      vim.keymap.set("n", "<leader>sb", function() require('fzf-lua').buffers() end)
      vim.keymap.set("n", "<leader>sh", function() require('fzf-lua').helptags() end)
      vim.keymap.set("n", "<leader>sf", function() require('fzf-lua').files() end)
      vim.keymap.set("n", "<leader>sc", function() require('fzf-lua').files({
        cmd='rg --files --follow conky sxhkd bspwm kitty mpd systemd zathura | sort',
        cwd='~/.config' 
      }) end)
      vim.keymap.set("n", "<leader>sq", function() require('fzf-lua').quickfix({
        ["winopts.fullscreen"] = true,
        ["winopts.preview.layout"] = "vertical",
        ["winopts.preview.vertical"] = "up:80%"
      }) end)
    end,
    opts = function(_, opts)
      local config = require("fzf-lua.config")
      config.defaults.keymap.fzf["ctrl-q"] = "select-all+accept"
    end,
    -- optional for icon support
    dependencies = { "nvim-tree/nvim-web-devicons" },
    -- config = function()
    --   -- calling `setup` is optional for customization
    --   require("fzf-lua").setup({})
    -- end,
  },
}


-- vim.g.fzf_layout = ??
-- return {
--     "junegunn/fzf.vim",
--     dependencies = { "junegunn/fzf", dir = "~/.fzf", build = "./install --all" }
-- }
-- -- vim: ts=2 sts=2 sw=2 et
