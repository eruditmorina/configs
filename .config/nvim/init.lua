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
-- more useful diffs (nvim -d)
--- by ignoring whitespace
vim.opt.diffopt:append('iwhite')
--- and using a smarter algorithm
--- https://vimways.org/2018/the-power-of-diff/
--- https://stackoverflow.com/questions/32365271/whats-the-difference-between-git-diff-patience-and-git-diff-histogram
--- https://luppeng.wordpress.com/2020/10/10/when-to-use-each-of-the-git-diff-algorithms/
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
-- plugin configuration
-------------------------------------------------------------------------------
-- get the manager
-- https://github.com/folke/lazy.nvim
-- Bootstrap lazy.nvim
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
require("lazy").setup({
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
    -- git decorations
    {
      "lewis6991/gitsigns.nvim",
      config = function()
        require("gitsigns").setup()
      end
    },
    -- fuzzy finder
	  {
		  'junegunn/fzf.vim',
      dependencies = { 'junegunn/fzf' },
		  config = function()
			  -- stop putting a giant window over my editor
			  vim.g.fzf_layout = { down = '~20%' }
        -- bring up :Files faster
        vim.keymap.set('n', '<leader>sf', ':Files<CR>', { desc = '[S]earch [F]iles' })
		  end
	  }
  }
})
