return {
    "X3eRo0/dired.nvim",
    dependencies = { "MunifTanjim/nui.nvim" },
    config = function()
        require("dired").setup {
            show_hidden = true,
            show_dot_dirs = true,
        }
    end
}
