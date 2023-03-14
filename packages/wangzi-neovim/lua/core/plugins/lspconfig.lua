-- local illuminate = require("illuminate")
local function setup_lsp(attach, capabilities)
    local lspconfig = require("lspconfig")
    -- lspservers with default config
    local servers = {
        "clangd",
        "lua_ls",
        "vimls",
        "pyright",
        "rust_analyzer",
        "gopls",
        "html",
        "tsserver",
        -- 'jsonls',
        "volar",
        "tailwindcss",
        "texlab",
        "yamlls",
        "cmake",
        "rnix",
    }
    for _, lsp in ipairs(servers) do
        lspconfig[lsp].setup({
            on_attach = function(client)
                attach(client)
                if lsp == "rust" then
                    require("packer").loader("rust_tools")
                end
                -- illuminate.on_attach(client)
            end,
            capabilities = capabilities,
            flags = {
                debounce_text_changes = 150,
            },
        })
    end
end

require("core.plugins.lsp_handlers")

local lsp_formatting = function(bufnr)
    vim.lsp.buf.format({
        filter = function(client)
            -- apply whatever logic you want (in this example, we'll only use null-ls)
            return client.name == "null-ls"
        end,
        bufnr = bufnr,
    })
end
local augroup = vim.api.nvim_create_augroup("LspFormatting", {})

local function on_attach(client, bufnr)
    if client.supports_method("textDocument/formatting") then
        vim.api.nvim_clear_autocmds({ group = augroup, buffer = bufnr })
        vim.api.nvim_create_autocmd("BufWritePre", {
            group = augroup,
            buffer = bufnr,
            callback = function()
                local old_print = vim.notify
                vim.notify = function(...) end
                lsp_formatting(bufnr)
                vim.notify = old_print
            end,
        })
    end

    local function map(mod, key, exec, opt)
        opt = opt or { noremap = true, silent = false }
        if key == "" then
            return
        end
        vim.api.nvim_set_keymap(mod, key, exec, opt)
    end

    local m = {
        declaration = "gD",
        definition = "",
        hover = "K",
        implementation = "",
        signature_help = "gk",
        add_workspace_folder = "<leader>wa",
        remove_workspace_folder = "<leader>wr",
        list_workspace_folders = "<leader>wl",
        type_definition = "",
        rename = "<leader>ra",
        references = "",
        float_diagnostics = "<leader>le",
        goto_prev = "[d",
        goto_next = "]d",
        set_loclist = "<leader>lq",
        formatting = "<leader>lf",
    }
    -- map("n", m.declaration, "<cmd>lua vim.lsp.buf.declaration()<CR>")
    -- map("n", m.definition, "<cmd>lua vim.lsp.buf.definition()<CR>")
    map("n", m.hover, "<cmd>lua vim.lsp.buf.hover()<CR>")
    map("n", m.implementation, "<cmd>lua vim.lsp.buf.implementation()<CR>")
    map("n", m.signature_help, "<cmd>lua vim.lsp.buf.signature_help()<CR>")
    map("n", m.add_workspace_folder, "<cmd>lua vim.lsp.buf.add_workspace_folder()<CR>")
    map("n", m.remove_workspace_folder, "<cmd>lua vim.lsp.buf.remove_workspace_folder()<CR>")
    map("n", m.list_workspace_folders, "<cmd>lua print(vim.inspect(vim.lsp.buf.list_workspace_folders()))<CR>")
    map("n", m.type_definition, "<cmd>lua vim.lsp.buf.type_definition()<CR>")
    map("n", m.rename, "<cmd>lua vim.lsp.buf.rename()<CR>")
    -- map("n", m.code_action, "<cmd>lua vim.lsp.buf.code_action()<CR>")
    map("n", m.references, "<cmd>lua vim.lsp.buf.references()<CR>")
    map("n", m.float_diagnostics, "<cmd>lua vim.diagnostic.open_float()<CR>")
    map("n", m.goto_prev, "<cmd>lua vim.diagnostic.goto_prev()<CR>")
    map("n", m.goto_next, "<cmd>lua vim.diagnostic.goto_next()<CR>")
    map("n", m.set_loclist, "<cmd>lua vim.diagnostic.setloclist()<CR>")
    map("n", m.formatting, "<cmd>lua vim.lsp.buf.format { async = true }<CR>", { silent = true })


    local keymap = vim.keymap.set
    keymap("n", "gd", "<cmd>Lspsaga peek_definition<CR>")
    keymap("n", "gD", "<cmd>Lspsaga goto_definition<CR>")
    keymap("n", "gr", "<cmd>Lspsaga rename<CR>")
    keymap("n", "gt", "<cmd>Lspsaga peek_type_definition<CR>")
    keymap("n", "gT", "<cmd>Lspsaga goto_type_definition<CR>")
    keymap("n", "gh", "<cmd>Lspsaga lsp_finder<CR>")
end

local capabilities = require('cmp_nvim_lsp').default_capabilities()
capabilities.textDocument.completion.completionItem.documentationFormat = { "markdown", "plaintext" }
capabilities.textDocument.completion.completionItem.snippetSupport = true
capabilities.textDocument.completion.completionItem.preselectSupport = true
capabilities.textDocument.completion.completionItem.insertReplaceSupport = true
capabilities.textDocument.completion.completionItem.labelDetailsSupport = true
capabilities.textDocument.completion.completionItem.deprecatedSupport = true
capabilities.textDocument.completion.completionItem.commitCharactersSupport = true
capabilities.textDocument.completion.completionItem.tagSupport = { valueSet = { 1 } }
capabilities.textDocument.completion.completionItem.resolveSupport = {
    properties = {
        "documentation",
        "detail",
        "additionalTextEdits",
    },
}
setup_lsp(on_attach, capabilities)
