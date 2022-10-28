require("nvim-treesitter.configs").setup({
    ensure_installed = {
        "lua",
        "vim",
        "rust",
        "nix",
        "c",
        "cpp",
        "java",
        "javascript",
        "typescript",
    },
    highlight = {
        enable = true,
    },
    parser_install_dir = vim.fn.stdpath("cache") .. "/treesitter",
    rainbow = {
        enable = true,
        -- disable = { "jsx", "cpp" }, list of languages you want to disable the plugin for
        extended_mode = true, -- Also highlight non-bracket delimiters like html tags, boolean or table: lang -> boolean
        max_file_lines = nil, -- Do not enable for files with more than n lines, int
        -- colors = {}, -- table of hex strings
        -- termcolors = {} -- table of colour name strings
    },
})
