-- ============================================================
-- Neovim configuration
-- Managed by ~/dev-setup
-- ============================================================

vim.g.mapleader = " "
vim.g.maplocalleader = " "

-- Basic editor settings
vim.opt.number = true
vim.opt.relativenumber = true
vim.opt.mouse = "a"
vim.opt.clipboard = "unnamedplus"

vim.opt.expandtab = true
vim.opt.shiftwidth = 4
vim.opt.tabstop = 4
vim.opt.smartindent = true

vim.opt.ignorecase = true
vim.opt.smartcase = true

vim.opt.splitright = true
vim.opt.splitbelow = true

vim.opt.termguicolors = true
vim.opt.signcolumn = "yes"

vim.opt.updatetime = 250
vim.opt.timeoutlen = 400

-- Persistent undo
vim.opt.undofile = true

-- Don't show mode in the command line (the statusline will handle it later)
vim.opt.showmode = false

-- Useful keybindings
vim.keymap.set("n", "<leader>w", "<cmd>write<cr>", { desc = "Save file" })
vim.keymap.set("n", "<leader>q", "<cmd>quit<cr>", { desc = "Quit" })

-- Better window navigation
vim.keymap.set("n", "<C-h>", "<C-w>h", { desc = "Move left" })
vim.keymap.set("n", "<C-j>", "<C-w>j", { desc = "Move down" })
vim.keymap.set("n", "<C-k>", "<C-w>k", { desc = "Move up" })
vim.keymap.set("n", "<C-l>", "<C-w>l", { desc = "Move right" })

-- ============================================================
-- Plugins
-- ============================================================

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

require("lazy").setup({
    {
        "thesimonho/kanagawa-paper.nvim",
        lazy = false,
        priority = 1000,
        opts = {
            style = "dark",
        },
        config = function(_, opts)
            require("kanagawa-paper").setup(opts)
            vim.cmd.colorscheme("kanagawa-paper-ink")
        end,
    },

    {
        "stevearc/oil.nvim",
        lazy = false,
        dependencies = {
            "nvim-tree/nvim-web-devicons",
        },
        opts = {
            view_options = {
                show_hidden = true,
            },
        },
        keys = {
            {
                "-",
                "<cmd>Oil<cr>",
                desc = "Open file explorer",
            },
        },
    },

    {
        "nvim-telescope/telescope.nvim",
        dependencies = {
            "nvim-lua/plenary.nvim",
        },
        config = function()
            local telescope = require("telescope.builtin")

            vim.keymap.set("n", "<C-p>", telescope.find_files, {
                desc = "Find files",
            })
        end,
    },

    {
        "nvim-treesitter/nvim-treesitter",
        build = ":TSUpdate",
        lazy = false,
        opts = {
            ensure_installed = {
                "python",
                "sql",
                "bash",
                "json",
                "yaml",
            },
        },
    },

 })

 -- Enable Treesitter highlighting
vim.api.nvim_create_autocmd("FileType", {
    pattern = {
        "python",
        "sql",
        "bash",
        "json",
        "yaml",
    },
    callback = function()
        vim.treesitter.start()
    end,
})

