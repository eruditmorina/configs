-- set <space> as the leader key
-- must happen before plugins are loaded (otherwise wrong leader will be used)
vim.g.mapleader = " "

-------------------------------------------------------------------------------
-- preferences
-------------------------------------------------------------------------------
-- never folding
vim.opt.foldenable = false
vim.opt.foldmethod = 'manual'
vim.opt.foldlevelstart = 99
-- keep more context on screen while scrolling
vim.opt.scrolloff = 2
-- never show line breaks if they're not there
vim.opt.wrap = false
-- always draw sign column. prevents buffer moving when adding/deleting sign
vim.opt.signcolumn = 'yes'
-- relative line numbers
-- vim.opt.relativenumber = true
-- show the absolute line number for the current line
vim.opt.number = true
-- keep current content top + left when splitting
vim.opt.splitright = true
vim.opt.splitbelow = true
-- infinite undo
-- ends up in ~/.local/state/nvim/undo/
vim.opt.undofile = true
-- Decent wildmenu
-- in completion, when there is more than one match,
-- list all matches, and only complete to longest common match
vim.opt.wildmode = 'list:longest'
-- when opening a file with a command (like :e),
-- don't suggest files from:
vim.opt.wildignore = '.hg,.svn,*~,*.png,*.jpg,*.gif,*.min.js,*.swp,*.o,vendor,dist,_site'
-- tabs vs spaces
vim.opt.shiftwidth = 2
vim.opt.tabstop = 2
vim.opt.expandtab = true
-- case-insensitive search/replace
vim.opt.ignorecase = true
-- unless uppercase in search term
vim.opt.smartcase = true
-- never ever make my terminal beep
vim.opt.vb = true
-- more useful diffs (nvim -d) by ignoring whitespace
vim.opt.diffopt:append('iwhite')
-- and using a smarter algorithm
-- https://vimways.org/2018/the-power-of-diff/
-- https://stackoverflow.com/questions/32365271/whats-the-difference-between-git-diff-patience-and-git-diff-histogram
-- https://luppeng.wordpress.com/2020/10/10/when-to-use-each-of-the-git-diff-algorithms/
vim.opt.diffopt:append('algorithm:histogram')
vim.opt.diffopt:append('indent-heuristic')
-- show the guide for long lines
vim.opt.colorcolumn = '120'
-- show more hidden characters
-- also, show tabs nicely
vim.opt.listchars = 'tab:^ ,nbsp:¬,extends:»,precedes:«,trail:•'
-- enable mouse mode
vim.opt.mouse = 'a'
-- sync clipboard
-- schedule the setting after `UiEnter` because it can increase startup-time
vim.schedule(function()
  vim.opt.clipboard = 'unnamedplus'
end)

-------------------------------------------------------------------------------
-- shortcuts
-------------------------------------------------------------------------------
-- search files
vim.keymap.set('', '<C-p>', '<cmd>Files<cr>')
-- search buffers
vim.keymap.set('n', '<leader>.', '<cmd>Buffers<cr>')

-------------------------------------------------------------------------------
-- plugin configuration
-------------------------------------------------------------------------------
-- get the manager: https://github.com/folke/lazy.nvim
local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not (vim.uv or vim.loop).fs_stat(lazypath) then
  local lazyrepo = "https://github.com/folke/lazy.nvim.git"
  local out = vim.fn.system({ "git", "clone", "--filter=blob:none", "--branch=stable", lazyrepo, lazypath })
  if vim.v.shell_error ~= 0 then
    vim.api.nvim_echo({
      { "Failed to clone lazy.nvim:\n", "ErrorMsg" },
      { out, "WarningMsg" },
      { "\nPress any key to exit..." },
    }, true, {})
    vim.fn.getchar()
    os.exit(1)
  end
end
vim.opt.rtp:prepend(lazypath)
-- Setup lazy.nvim
require("lazy").setup {
  {
    -- main color scheme
    {
      "wincent/base16-nvim",
      lazy = false, -- load at start
      priority = 1000, -- load first
      config = function()
        vim.cmd([[colorscheme base16-gruvbox-dark-hard]])
        vim.o.background = 'dark'
        -- Make comments more prominent -- they are important.
        local bools = vim.api.nvim_get_hl(0, { name = 'Boolean' })
        vim.api.nvim_set_hl(0, 'Comment', bools)
        -- Make it clearly visible which argument we're at.
        local marked = vim.api.nvim_get_hl(0, { name = 'PMenu' })
        vim.api.nvim_set_hl(0, 'LspSignatureActiveParameter', { fg = marked.fg, bg = marked.bg, ctermfg = marked.ctermfg, ctermbg = marked.ctermbg, bold = true })
      end
    },
    -- nice bottom bar
    {
      'itchyny/lightline.vim',
      lazy = false, -- also load at start since it's UI
      config = function()
        -- no need to also show mode in cmd line when we have bar
        vim.o.showmode = false
        vim.g.lightline = {
          active = {
            left = {
              { 'mode', 'paste' },
              { 'readonly', 'filename', 'modified' }
            },
            right = {
              { 'lineinfo' },
              { 'percent' },
              { 'fileencoding', 'filetype' }
            },
          },
          component_function = {
            filename = 'LightlineFilename'
          },
        }
        function LightlineFilenameInLua(opts)
          if vim.fn.expand('%:t') == '' then
            return '[No Name]'
          else
            return vim.fn.getreg('%')
          end
        end
        -- https://github.com/itchyny/lightline.vim/issues/657
        vim.api.nvim_exec(
          [[
          function! g:LightlineFilename()
            return v:lua.LightlineFilenameInLua()
          endfunction
          ]],
          true
        )
      end
    },
    -- fuzzy finder
    {
      'junegunn/fzf.vim',
      dependencies = { 'junegunn/fzf' },
      config = function()
        -- stop putting a giant window over my editor
        vim.g.fzf_layout = { down = '~20%' }
      end
    },
    -- LSP Configs
    {
      'neovim/nvim-lspconfig',
      config = function()
        -- setup language servers
        local lspconfig = require('lspconfig')
        -- Pyright
        lspconfig.pyright.setup {
          settings = {
            pyright = {
              disableOrganizeImports = true, -- Using Ruff's import organizer
            },
            python = {
              analysis = {
                ignore = { '*' }, -- Ignore all files for analysis to exclusively use Ruff for linting
                typeCheckingMode = 'off', -- use Mypy instead
              },
            },
          },
        }
        -- Ruff
        lspconfig.ruff.setup {}
        vim.api.nvim_create_autocmd("LspAttach", {
          group = vim.api.nvim_create_augroup('lsp_attach_disable_ruff_hover', { clear = true }),
          callback = function(args)
            local client = vim.lsp.get_client_by_id(args.data.client_id)
            if client == nil then
              return
            end
            if client.name == 'ruff' then
              -- Disable hover in favor of Pyright
              client.server_capabilities.hoverProvider = false
            end
          end,
          desc = 'LSP: Disable hover capability from Ruff',
        })
        -- Rust
        lspconfig.rust_analyzer.setup {
          settings = {
            ['rust-analyzer'] = {
              cargo = { features = "all" }
            }
          }
        }
      end
    },
    -- linter
    {
      'mfussenegger/nvim-lint',
      config = function()
        require("lint").linters_by_ft = {
          python = { "mypy" }
        }
        vim.api.nvim_create_autocmd({ "BufWritePost", "BufReadPost" }, {
          callback = function()
            -- try_lint without arguments runs the linters defined in `linters_by_ft` for the current filetype
            require("lint").try_lint()
          end
        })
      end
    },
    -- auto formatter
    {
      'stevearc/conform.nvim',
      config = function()
        require("conform").setup {
          formatters_by_ft = {
            python = { "ruff_fix", "ruff_format", "ruff_organize_imports" },
          },
          format_on_save = { lsp_format = "fallback" }
        }
      end
    },
    -- LSP based code completion
    {
      "hrsh7th/nvim-cmp",
      -- load cmp on InsertEnter
      event = "InsertEnter",
      -- dependencies will only be loaded when cmp loads
      dependencies = {
        'neovim/nvim-lspconfig',
        'hrsh7th/cmp-nvim-lsp',
        'hrsh7th/cmp-buffer',
        'hrsh7th/cmp-path',
      },
      config = function()
        local cmp = require'cmp'
        cmp.setup({
          snippet = {
            -- REQUIRED - must specify a snippet engine
            expand = function(args)
              vim.fn["vsnip#anonymous"](args.body)
            end,
          },
          mapping = cmp.mapping.preset.insert({
            ['<C-b>'] = cmp.mapping.scroll_docs(-4),
            ['<C-f>'] = cmp.mapping.scroll_docs(4),
            ['<C-Space>'] = cmp.mapping.complete(),
            ['<C-e>'] = cmp.mapping.abort(),
            -- Accept currently selected item. Set `select` to `false` to only confirm explicitly selected items.
            ['<CR>'] = cmp.mapping.confirm({ select = true }),
          }),
          sources = cmp.config.sources({
            { name = 'nvim_lsp' },
          }, {
            { name = 'buffer' },
          }),
          performance = { debounce = 0, throttle = 0 },
        })
        -- enable completing paths in ':'
        cmp.setup.cmdline(':', {
          sources = cmp.config.sources({
            { name = 'path' }
          })
        })
      end
    },
    -- inline function signature
    {
      "ray-x/lsp_signature.nvim",
      event = "VeryLazy",
      opts = {
        doc_lines = 0,
        handler_opts = { border = "none" },
      },
      config = function(_, opts) require'lsp_signature'.setup(opts) end
    },
    -- syntax highlighting
    {
      "nvim-treesitter/nvim-treesitter",
      build = ":TSUpdate",
      config = function ()
        local configs = require("nvim-treesitter.configs")
        configs.setup {
          ensure_installed = { "javascript", "markdown", "python", "rust", "typescript", "vim", "vimdoc" },
          sync_install = false,
          auto_install = false,
          highlight = { enable = true },
        }
      end
    }
  }
}
