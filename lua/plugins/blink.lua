return {
  'saghen/blink.cmp',
  -- optional: provides snippets for the snippet source
  -- dependencies = { 'rafamadriz/friendly-snippets' },
  -- build = 'cargo build --release',
  dependencies = { 
    "mikavilpas/blink-ripgrep.nvim",
  },

  version = '1.*',
  ---@module 'blink.cmp'
  ---@type blink.cmp.Config
  opts = {
    keymap = { preset = 'default' },

    appearance = {
      nerd_font_variant = 'mono'
    },

    completion = { documentation = { auto_show = true } },

    sources = {
      default = { 'lsp', 'path', 'snippets', 'buffer', 'ripgrep' },
      providers = {
        -- 👇🏻👇🏻 add the ripgrep provider config below
        ripgrep = {
          module = "blink-ripgrep",
          name = "Ripgrep",
          opts = {
            prefix_min_len = 3,
            project_root_marker = ".git",
            fallback_to_regex_highlighting = true,
            toggles = {
              on_off = nil,
            },
            backend = {
              use = "ripgrep",
              context_size = 5,
              ripgrep = {
                additional_paths = { '/home/saj/Documents/txt/de.dict' },
                additional_rg_options = {},
                ignore_paths = { '/home/saj' },
                max_filesize = "1M",
                project_root_fallback = true,
                search_casing = "--ignore-case",
              },
            },

            debug = true,
          },
          transform_items = function(_, items)
            for _, item in ipairs(items) do
              -- example: append a description to easily distinguish rg results
              item.labelDetails = {
                description = "(rg)",
              }
            end
            return items
          end,
        },
      },
    },

    fuzzy = { implementation = "prefer_rust_with_warning" }
  },
  opts_extend = { "sources.default" }
}
