require("lazy").setup({
  spec = {
    -- import your plugins
    { import = "plugins" },
  },
  -- automatically check for plugin updates
  checker = { enabled = false },
})
-- vim: ts=2 sts=2 sw=2 et
