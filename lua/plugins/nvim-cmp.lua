return {
    "hrsh7th/nvim-cmp",
    dependencies = { 
        "hrsh7th/cmp-buffer",     -- source for text in buffer
        "hrsh7th/cmp-path",       -- source for file system paths
        -- "lukas-reineke/cmp-rg",   -- source for dictionary

        -- "uga-rosa/cmp-dictionary" -- source for dictionary
    },
    config = function()
        local cmp = require("cmp")

        cmp.setup({
            -- snippet = {
            --     expand = function(args)
            --         luasnip.lsp_expand(args.body)
            --     end,
            -- },
            mapping = cmp.mapping.preset.insert({
                ["<C-d>"] = cmp.mapping.scroll_docs(-4),
                ["<C-f>"] = cmp.mapping.scroll_docs(4),
                ["<C-Space>"] = cmp.mapping.complete(),
                ["<C-e>"] = cmp.mapping.close(),
                ["<CR>"] = cmp.mapping.confirm({
                    behavior = cmp.ConfirmBehavior.Replace,
                    select = true,
                }),
            }),
            sources = cmp.config.sources({
                { name = "buffer" },
                { name = "path" },
                -- { name = 'rg', option = { cwd = "/home/saj/Downloads/deutsch" }, keyword_length = 3 };
                -- { name = "dictionary" },
            }),
        })

        -- cmp_dictionary
        -- require("cmp_dictionary").setup({
        --     paths = { "/home/saj/Downloads/deutsch/wordlist-german.txt" },
        --     exact_length = 2,
        -- })
    end
}
