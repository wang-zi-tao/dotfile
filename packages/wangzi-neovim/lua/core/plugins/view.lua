return {
    {
        "mbbill/undotree",
        dir = gen.undotree,
        name = "undotree",
        cmd = "UndotreeToggle",
        lazy = true,
        keys = {
            { "<leader>u", "<cmd>UndotreeToggle<CR>", mode = "n", desc = "Undo Tree" },
        },
    },
    {
        "sindrets/diffview.nvim",
        dir = gen.diffview,
        name = "diffview",
        dependencies = "plenary_nvim",
        module = "diffview",
        lazy = true,
        cmd = {
            "DiffviewOpen",
            "DiffviewClose",
            "DiffviewClose",
            "DiffviewFocusFiles",
            "DiffviewRefresh",
            "DiffviewFileHistory",
        },
        config = function()
            require("diffview").setup({})
        end,
        keys = {
            {
                "<leader>gd",
                function()
                    require("diffview").open()
                end,
                desc = "Open Diff",
            },
            {
                "<leader>gD",
                function()
                    require("diffview").close()
                end,
                desc = "Close Diff",
            },
            {
                "<leader>gh",
                function()
                    require("diffview").file_history()
                end,
                desc = "Git Log",
            },
            {
                "<leader>gH",
                function()
                    vim.cmd.DiffviewFileHistory("%")
                end,
                desc = "Git Log This File",
            },
            { "<leader>gf", "<cmd>DiffviewFileHistory %<CR>", desc = "File History" },
        },
    },
    gen.markdown_preview and {
        "davidgranstrom/nvim-markdown-preview",
        dir = gen.markdown_preview,
        name = "markdown_preview",
        ft = "markdown",
        cmd = "MarkdownPreview",
        lazy = true,
    } or {},
    {
        "MeanderingProgrammer/render-markdown.nvim",
        dir = gen.render_markdown,
        name = "render_markdown",
        dependencies = { "nvim_treesitter", "nvim_web_devicons" },
        module = "render-markdown",
        cmd = "RenderMarkdown",
        ft = { "markdown", "lsp_markdown", "vimwiki" },
        setup = function()
            vim.treesitter.language.register('markdown', 'vimwiki')
        end,
        config = function()
            require('obsidian').get_client().opts.ui.enable = false
            vim.api.nvim_buf_clear_namespace(0, vim.api.nvim_get_namespaces()['ObsidianUI'], 0, -1)

            require('render-markdown').setup({})
        end,
    }
}
