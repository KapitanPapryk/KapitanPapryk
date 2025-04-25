vim.g.mapleader = " "
-- lua init steeings for vim that shows number and relative number
vim.opt.number = true
vim.opt.relativenumber = true
vim.opt.hlsearch = false
vim.opt.incsearch = true
vim.opt.colorcolumn = "80,120"

vim.opt.tabstop = 4
vim.opt.softtabstop = 4
vim.opt.shiftwidth = 4
vim.opt.expandtab = true

vim.opt.smartindent = true
vim.opt.scrolloff = 8

-- :map [[ ?{<CR>w99[{
-- :map ][ /}<CR>b99]}
-- :map ]] j0[[%/{<CR>
-- :map [] k$][%?}<CR>
-- rewrite in lua
-- vim.keymap.set({ "n" }, "[[", function() vim.cmd("normal ?{\<CR>w99[{") end, { silent = true })
-- vim.keymap.set({ "n" }, "][", function() vim.cmd("normal /}\<CR>b99]}") end, { silent = true })
-- vim.keymap.set({ "n" }, "]]", function() vim.cmd("normal j0[[%/{\<CR>") end, { silent = true })
-- vim.keymap.set({ "n" }, "[]", function() vim.cmd("normal k$][%?}\<CR>") end, { silent = true })



local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not vim.loop.fs_stat(lazypath) then
    vim.fn.system({
        "git",
        "clone",
        "--filter=blob:none",
        "https://github.com/folke/lazy.nvim.git",
        "--branch=stable", -- latest stable release
        lazypath,
    })
end
vim.opt.rtp:prepend(lazypath)

require("lazy").setup({
    {
        "ellisonleao/gruvbox.nvim",
        priority = 1000,
        config = true,
        opts = ...
    },
    { 'mg979/vim-visual-multi' },
    { 'tpope/vim-fugitive' },
    { 'williamboman/mason.nvim' },
    { 'williamboman/mason-lspconfig.nvim' },
    {
        'VonHeikemen/lsp-zero.nvim',
        branch = 'v3.x'
    },
    { 'neovim/nvim-lspconfig' },
    { 'github/copilot.vim' },
    { 'hrsh7th/cmp-nvim-lsp' },
    { 'hrsh7th/cmp-buffer' },
    { 'hrsh7th/cmp-path' },
    { 'hrsh7th/cmp-cmdline' },
    { 'hrsh7th/nvim-cmp' },
    { 'saadparwaiz1/cmp_luasnip' },
    {
        'L3MON4D3/LuaSnip',
        version = "v2.*",
        dependencies = { "rafamadriz/friendly-snippets" },
    },
    { 'nvim-treesitter/nvim-treesitter' },
    { 'mbbill/undotree' },
    {
        'nvim-telescope/telescope.nvim',
        branch = '0.1.x',
        dependencies = { 'nvim-lua/plenary.nvim' }
    },
    {
        "iamcco/markdown-preview.nvim",
        cmd = {
            "MarkdownPreviewToggle",
            "MarkdownPreview",
            "MarkdownPreviewStop"
        },
        ft = { "markdown" },
        build = function() vim.fn["mkdp#util#install"]() end,
    },
})

vim.o.background = "dark" -- or "light" for light mode
vim.cmd([[colorscheme gruvbox]])

local lsp_zero = require('lsp-zero')
lsp_zero.preset('recommended')
lsp_zero.on_attach(function(client, bufnr)
    lsp_zero.default_keymaps({ buffer = bufnr })
end)
lsp_zero.setup()

require('mason').setup({})

require('mason-lspconfig').setup({
    ensure_installed = { 'lua_ls', 'rust_analyzer', 'clangd', 'biome', 'cmake',
        'dockerls', 'html', 'grammarly', 'zls' },
    handlers = {
        lsp_zero.default_setup,
    },
})

require 'nvim-treesitter.configs'.setup {
    -- A list of parser names, or "all"
    ensure_installed = { "javascript", "typescript", "c", "lua", "rust",
        "python", "gdscript", "html", "css", "sql", "markdown", "org" },

    -- Install parsers synchronously (only applied to `ensure_installed`)
    sync_install = false,

    -- Automatically install missing parsers when entering buffer
    -- Recommendation: set to false if you don't have `tree-sitter` CLI installed locally
    auto_install = true,

    highlight = {
        -- `false` will disable the whole extension
        enable = true,

        -- Setting this to true will run `:h syntax` and tree-sitter at the same time.
        -- Set this to `true` if you depend on 'syntax' being enabled (like for indentation).
        -- Using this option may slow down your editor, and you may see some duplicate highlights.
        -- Instead of true it can also be a list of languages
        additional_vim_regex_highlighting = false,
    },
}


local builtin = require('telescope.builtin')

--- TODO: What is expand?
vim.keymap.set({ "i" }, "<C-s>e", function() ls.expand() end, { silent = true })

vim.keymap.set({ "i", "s" }, "<C-s>;", function() ls.jump(1) end, { silent = true })
vim.keymap.set({ "i", "s" }, "<C-s>,", function() ls.jump(-1) end, { silent = true })

vim.keymap.set({ "i", "s" }, "<C-E>", function()
    if ls.choice_active() then
        ls.change_choice(1)
    end
end, { silent = true })

vim.keymap.set('n', '<leader>ff', builtin.find_files, {})
vim.keymap.set('n', '<leader>fg', builtin.live_grep, {})
vim.keymap.set('n', '<leader>fb', builtin.buffers, {})
vim.keymap.set('n', '<leader>fh', builtin.help_tags, {})

vim.keymap.set("n", "<leader>pv", vim.cmd.Ex)
vim.keymap.set("n", "<leader>u", vim.cmd.UndotreeToggle)

local ls = require("luasnip")
ls.filetype_extend("javascript", { "jsdoc" })
local cmp = require('cmp')
local cmp_format = lsp_zero.cmp_format({ details = true })
cmp.setup({
    sources = {
        { name = 'nvim_lsp' },
        { name = 'luasnip' },
        { name = 'buffer' },
        { name = 'path' },
    },
    --- (Optional) Show source name in completion menu
    formatting = cmp_format,
})
cmp.setup.cmdline('/', {
    mapping = cmp.mapping.preset.cmdline(),
    sources = {
        { name = 'buffer' }
    }
})
cmp.setup.cmdline(':', {
    mapping = cmp.mapping.preset.cmdline(),
    sources = cmp.config.sources({
        { name = 'path' }
    }, {
        {
            name = 'cmdline',
            option = {
                ignore_cmds = { 'Man', '!' }
            }
        }
    })
})
require("luasnip.loaders.from_vscode").lazy_load()

-- markdown
vim.g.mkdp_auto_start = 1
