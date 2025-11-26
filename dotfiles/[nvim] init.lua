-- ========= BASIC OPTIONS =========
vim.g.mapleader = " "

local opt = vim.opt

-- UI
opt.number = true
opt.termguicolors = true
opt.cursorline = true

-- Tabs / indent
opt.expandtab = true
opt.shiftwidth = 4
opt.tabstop   = 4
opt.smartindent = true

-- QoL
opt.mouse = "a"
opt.clipboard = "unnamedplus"
opt.ignorecase = true
opt.smartcase = true
opt.splitright = true
opt.splitbelow = true

-- ========= KEYMAPS =========
local map = vim.keymap.set

-- Save with Ctrl+S
map("n", "<C-s>", ":w<CR>", { silent = true })
map({ "i", "v" }, "<C-s>", "<Esc>:w<CR>", { silent = true })

-- Quit with Ctrl+Q
map("n", "<C-q>", ":q<CR>", { silent = true })

-- Clear search highlight
map("n", "<leader>h", ":nohlsearch<CR>", { silent = true })

-- ========= LAZY.NVIM BOOTSTRAP =========
local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not vim.loop.fs_stat(lazypath) then
  vim.fn.system({
    "git",
    "clone",
    "--filter=blob:none",
    "https://github.com/folke/lazy.nvim.git",
    "--branch=stable",
    lazypath,
  })
end
vim.opt.rtp:prepend(lazypath)

-- ========= PLUGINS =========
require("lazy").setup({
  -- Colorscheme
  {
    "folke/tokyonight.nvim",
    lazy = false,
    priority = 1000,
    opts = {
      style = "night",
      transparent = false,
    },
  },

  -- Statusline
  {
    "nvim-lualine/lualine.nvim",
    dependencies = { "nvim-tree/nvim-web-devicons" },
    opts = {
      options = {
        theme = "tokyonight",
        section_separators = "",
        component_separators = "",
      },
    },
  },

  -- File tree
  {
    "nvim-tree/nvim-tree.lua",
    dependencies = { "nvim-tree/nvim-web-devicons" },
  },

  -- Fuzzy finder
  {
    "nvim-telescope/telescope.nvim",
    branch = "0.1.x",
    dependencies = { "nvim-lua/plenary.nvim" },
  },

  -- Treesitter (better syntax highlighting)
  {
    "nvim-treesitter/nvim-treesitter",
    build = ":TSUpdate",
  },

  -- LSP support
  "neovim/nvim-lspconfig",

  -- Autocomplete (nvim-cmp) + snippets (LuaSnip)
  {
    "hrsh7th/nvim-cmp",
    dependencies = {
      "hrsh7th/cmp-nvim-lsp",
      "hrsh7th/cmp-buffer",
      "hrsh7th/cmp-path",
      "L3MON4D3/LuaSnip",
      "saadparwaiz1/cmp_luasnip",
    },
  },
})

-- ========= AFTER PLUGINS LOAD =========

-- Colorscheme
vim.cmd.colorscheme("tokyonight")

-- ---- File tree ----
require("nvim-tree").setup({
  view = { width = 30 },
  renderer = { group_empty = true },
  filters = { dotfiles = false },
})
-- Toggle file tree
map("n", "<leader>e", ":NvimTreeToggle<CR>", { silent = true })

-- ---- Telescope ----
map("n", "<leader>ff", "<cmd>Telescope find_files<CR>", { silent = true })
map("n", "<leader>fg", "<cmd>Telescope live_grep<CR>", { silent = true })
map("n", "<leader>fb", "<cmd>Telescope buffers<CR>", { silent = true })
map("n", "<leader>fh", "<cmd>Telescope help_tags<CR>", { silent = true })

-- ---- Treesitter ----
require("nvim-treesitter.configs").setup({
  ensure_installed = { "lua", "python", "javascript", "typescript", "bash", "html", "css", "json" },
  highlight = { enable = true },
  indent = { enable = true },
})

-- ========= AUTOCOMPLETE (nvim-cmp + LuaSnip) =========
local cmp = require("cmp")
local luasnip = require("luasnip")

cmp.setup({
  snippet = {
    expand = function(args)
      luasnip.lsp_expand(args.body)
    end,
  },
  mapping = cmp.mapping.preset.insert({
    ["<C-b>"] = cmp.mapping.scroll_docs(-4),
    ["<C-f>"] = cmp.mapping.scroll_docs(4),
    ["<C-Space>"] = cmp.mapping.complete(),   -- manually open menu
    ["<C-e>"] = cmp.mapping.abort(),          -- close menu
    ["<CR>"] = cmp.mapping.confirm({ select = true }), -- confirm selection
    ["<Tab>"] = cmp.mapping(function(fallback)
      if cmp.visible() then
        cmp.select_next_item()
      elseif luasnip.expand_or_jumpable() then
        luasnip.expand_or_jump()
      else
        fallback()
      end
    end, { "i", "s" }),
    ["<S-Tab>"] = cmp.mapping(function(fallback)
      if cmp.visible() then
        cmp.select_prev_item()
      elseif luasnip.jumpable(-1) then
        luasnip.jump(-1)
      else
        fallback()
      end
    end, { "i", "s" }),
  }),
  sources = cmp.config.sources({
    { name = "nvim_lsp" },
    { name = "luasnip" },
  }, {
    { name = "buffer" },
    { name = "path" },
  }),
})

-- ========= LSP (Language Servers) =========
local capabilities = require("cmp_nvim_lsp").default_capabilities()

-- Lua (for Neovim config)
vim.lsp.config('lua_ls', {
  capabilities = capabilities,
  settings = {
    Lua = {
      diagnostics = {
        globals = { "vim" },
      },
    },
  },
})

-- Python
vim.lsp.config('pyright', {
  capabilities = capabilities,
})

-- JavaScript / TypeScript
-- tsserver is deprecated, new name is ts_ls
vim.lsp.config('ts_ls', {
  capabilities = capabilities,
})

-- C / C++
vim.lsp.config('clangd', {
  capabilities = capabilities,
})

-- Bash
vim.lsp.config('bashls', {
  capabilities = capabilities,
})

-- YAML
vim.lsp.config('yamlls', {
  capabilities = capabilities,
})

-- Markdown
vim.lsp.config('marksman', {
  capabilities = capabilities,
})

-- Dockerfile
vim.lsp.config('dockerls', {
  capabilities = capabilities,
})

-- Enable the servers
vim.lsp.enable({
  'lua_ls',
  'pyright',
  'ts_ls',
  'clangd',
  'bashls',
  'yamlls',
  'marksman',
  'dockerls',
})
