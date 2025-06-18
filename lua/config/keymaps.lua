-- Keymaps are automatically loaded on the VeryLazy event
-- Default keymaps that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/keymaps.lua
-- Add any additional keymaps here
local map = vim.keymap.set

-- Helper function to safely override existing keymaps
local function override_map(mode, lhs, rhs, opts)
  pcall(vim.keymap.del, mode, lhs)
  map(mode, lhs, rhs, opts)
end
-- Delete on 'q' (next to 'w' where change is)
map({ "n", "o", "x" }, "x", "d", { desc = "Delete" })

-- Up/down/left/right
map({ "n", "o", "x" }, "h", "h", { desc = "Left (h)" })
map({ "n", "o", "x" }, "e", "k", { desc = "Up (k)" })
map({ "n", "o", "x" }, "a", "j", { desc = "Down (j)" })
map({ "n", "o", "x" }, "i", "l", { desc = "Right (l)" })

-- Line operations and find
map({ "n" }, "j", "o", { desc = "Open line below" })
map({ "n" }, "J", "O", { desc = "Open line above" })
-- f is now default (find character forward)
-- F is default (find character backward)

-- Beginning/end of line

map({ "n", "o", "x" }, "0", "0", { desc = "Beginning of line" })
map({ "n", "o", "x" }, "p", "^", { desc = "First non-blank character" })
map({ "n", "o", "x" }, ".", "$", { desc = "End of line" })

-- PageUp/PageDown
map({ "n", "x" }, "<C-.>", "<PageUp>", { desc = "Page Up" })
map({ "n", "x" }, "<C-p>", "<PageDown>", { desc = "Page Down" })

-- Jumplist navigation
-- map({ "n" }, "<C-e>", "<C-i>", { desc = "Jumplist forward" })
-- map({ "n" }, "<C-a>", "<C-o>", { desc = "Jumplist backward" })

-- Word left/right
map({ "n", "o", "x" }, "l", "b", { desc = "Word back" })
map({ "n", "o", "x" }, "d", "w", { desc = "Word forward" })
map({ "n", "o", "x" }, "L", "B", { desc = "WORD back" })
map({ "n", "o", "x" }, "D", "W", { desc = "WORD forward" })

-- Move lines with Alt+A/E
map({ "n" }, "<M-C-a>", "<cmd>move .+1<cr>==", { desc = "Move line down" })
map({ "n" }, "<M-C-e>", "<cmd>move .-2<cr>==", { desc = "Move line up" })

-- Search navigation (moved from <C-f> due to jumplist conflict)
map({ "n", "o", "x" }, "<C-s>", "n", { desc = "Next search match" })
map({ "n", "o", "x" }, "<C-S>", "N", { desc = "Previous search match" })

-- Repeat find
map({ "n", "o", "x" }, ";", ";", { desc = "Repeat find forward" })
map({ "n", "o", "x" }, "-", ",", { desc = "Repeat find backward" })

map({ "n", "o", "x" }, "%", "%", { desc = "Jump to matching bracket" })

-- End of word left/right
map({ "n", "o", "x" }, "H", "ge", { desc = "End of word back" })
map({ "n", "o", "x" }, "<M-h>", "gE", { desc = "End of WORD back" })
map({ "n", "o", "x" }, "<M-o>", "E", { desc = "End of WORD forward" })

-- Text objects - r and t are reserved for treesitter multi-key objects
-- Use manual mappings only for simple cases
-- diw is drw. daw is now dtw.

-- -- Simple operator-pending mappings for nvim-surround (using treesitter text objects)

-- Keep visual replace on a different key
map({ "v" }, "R", "r", { desc = "Replace selected text" })

-- Folds
map({ "n", "x" }, "b", "z", { desc = "Fold commands" })
map({ "n", "x" }, "bb", "zb", { desc = "Scroll line and cursor to bottom" })
map({ "n", "x" }, "ba", "zj", { desc = "Move down to fold" })
map({ "n", "x" }, "be", "zk", { desc = "Move up to fold" })

-- Copy/paste
map({ "n", "o", "x" }, "c", "y", { desc = "Yank (copy)" })
map({ "n", "x" }, "v", "p", { desc = "Paste" })
map({ "n" }, "C", "y$", { desc = "Yank to end of line" })
map({ "x" }, "C", "y", { desc = "Yank selection" })
map({ "n", "x" }, "V", "P", { desc = "Paste before" })
map({ "v" }, "V", "P", { desc = "Paste without losing clipboard" })

-- Inline paste (avoids creating new lines)
local function paste_inline()
  local reg_type = vim.fn.getregtype('"')
  if reg_type == "V" then -- line-wise register
    vim.cmd("normal! gp")
  else
    vim.cmd("normal! p")
  end
end

map({ "n", "x" }, "-", paste_inline, { desc = "Paste inline" })

-- Undo/redo
map({ "n" }, "z", "u", { desc = "Undo" })
map({ "n" }, "<S-u>", "U", { desc = "Undo line" })
map({ "n" }, "<C-u>", "<C-r>", { desc = "Redo" })

-- Jumplist navigation
map({ "n" }, "o", "<C-o>", { desc = "Jumplist backward" })
map({ "n" }, "<C-o>", "<C-i>", { desc = "Jumplist forward" })

-- Insert/append
map({ "n" }, "r", "i", { desc = "Insert before cursor" })
-- map({ "n" }, "T", "I", { desc = "Insert at start of line" })
map({ "n" }, "t", "a", { desc = "Insert after cursor" })
-- map({ "n" }, "S", "A", { desc = "Insert at end of line" })

-- Normal mode - Direct commenting with next line
map("n", "<C-/>", function()
  -- Call vim's native comment function directly
  vim.cmd("normal! " .. vim.api.nvim_replace_termcodes("gcc", true, false, true))
  vim.cmd("normal! j")
end, { desc = "Toggle comment and go to next line" })

map("n", "<C-_>", function()
  -- Call vim's native comment function directly
  vim.cmd("normal! " .. vim.api.nvim_replace_termcodes("gcc", true, false, true))
  vim.cmd("normal! j")
end, { desc = "Toggle comment and go to next line" })

-- Visual mode - Robust block commenting
map("v", "<C-/>", function()
  local ok, comment_api = pcall(require, "Comment.api")
  if ok then
    comment_api.toggle.linewise(vim.fn.visualmode())
  else
    vim.cmd("'<,'>normal! gcc")
  end
end, { desc = "Toggle comment (visual)" })

map("v", "<C-_>", function()
  local ok, comment_api = pcall(require, "Comment.api")
  if ok then
    comment_api.toggle.linewise(vim.fn.visualmode())
  else
    vim.cmd("'<,'>normal! gcc")
  end
end, { desc = "Toggle comment (visual)" })

-- Change
map({ "n", "o", "x" }, "w", "c", { desc = "Change" })
map({ "n", "x" }, "W", "C", { desc = "Change to end of line" })

-- Visual mode
map({ "n", "x" }, "n", "v", { desc = "Visual mode" })
map({ "n", "x" }, "N", "V", { desc = "Visual line mode" })
-- Add Visual block mode
map({ "n" }, "<C-n>", "<C-v>", { desc = "Visual block mode" })

-- Override HAEI navigation in visual modes (including visual line mode)
-- Use noremap to fully override default vim behavior including text objects
vim.keymap.set("x", "e", "k", { noremap = true, desc = "Up in visual modes" })
vim.keymap.set("x", "a", "j", { noremap = true, desc = "Down in visual modes" })
vim.keymap.set("x", "h", "h", { noremap = true, desc = "Left in visual modes" })
vim.keymap.set("x", "i", "l", { noremap = true, desc = "Right in visual modes" })

-- Insert in Visual mode
map({ "v" }, "S", "I", { desc = "Insert at start of selection" })

map({ "n", "o", "x" }, "m", "n", { desc = "Next search match" })
map({ "n", "o", "x" }, "M", "N", { desc = "Previous search match" })

map({ "n" }, "<leader>gn", "<cmd>:Neogit cwd=%:p:h<CR>", { desc = "Open neogit" })
map({ "n" }, "<leader>gh", function()
  Snacks.terminal("gh dash", { win = { style = "terminal" } })
end, { desc = "Open GitHub dashboard" })

-- Lazygit
map({ "n" }, "<leader>gz", function()
  Snacks.lazygit()
end, { desc = "Lazygit (Root Dir)" })
map({ "n" }, "<leader>gZ", function()
  Snacks.lazygit({ cwd = LazyVim.root.get() })
end, { desc = "Lazygit (cwd)" })
-- 'til
map({ "n", "o", "x" }, "k", "t", { desc = "Till before" })
map({ "n", "o", "x" }, "K", "T", { desc = "Till before backward" })

-- Fix diffput (t for 'transfer')
-- map({ "n" }, "dt", "dp", { desc = "diffput (t for 'transfer')" })

-- Force override any plugin mappings for Q
vim.keymap.set("n", "Q", "@q", { desc = "replay the 'q' macro", silent = true, noremap = true })

-- Cursor to bottom of screen
-- H and M haven't been remapped, only L needs to be mapped
map({ "n" }, "B", "L", { desc = "Move to bottom of screen" })
map({ "v" }, "B", "L", { desc = "Move to bottom of screen" })
map({ "n", "v" }, "H", "H", { desc = "Move to top of screen" })

-- Misc overridden keys must be prefixed with g
map({ "n", "x" }, "gX", "X", { desc = "Delete before cursor" })
map({ "n", "x" }, "gU", "U", { desc = "Uppercase" })
map({ "n", "x" }, "gQ", "Q", { desc = "Ex mode" })
map({ "n", "x" }, "gK", "K", { desc = "Lookup keyword" })
-- extra alias (now main since K is remapped)
map({ "n", "x" }, "gh", "K", { desc = "Lookup keyword" })

-- Disable spawning empty buffer when closing last buffer
vim.api.nvim_create_autocmd("User", {
  pattern = "BufferClose",
  callback = function()
    local bufs = vim.tbl_filter(function(buf)
      return vim.api.nvim_buf_is_loaded(buf) and vim.bo[buf].buflisted
    end, vim.api.nvim_list_bufs())

    if #bufs == 0 then
      vim.schedule(function()
        require("snacks").dashboard()
      end)
    end
  end,
})

-- Window navigation - cycle through windows
map({ "n" }, "<C-h>", "<C-w>w", { desc = "Previous window" })
map({ "n" }, "<C-i>", "<C-w>W", { desc = "Next window" })
-- Directional window navigation (commented out due to buffer nav conflicts)
-- map({ "n" }, "<C-a>", "<C-w>j", { desc = "Window down" })
-- map({ "n" }, "<C-e>", "<C-w>k", { desc = "Window up" })

-- Add some commonly used editor operations
map({ "n" }, "<leader>fs", ":w<CR>", { desc = "Save file" })
map({ "n" }, "<leader>q", ":q<CR>", { desc = "Quit" })
map({ "n" }, "<leader>Q", ":qa<CR>", { desc = "Quit all" })
map({ "n" }, "<leader>rr", function()
  vim.cmd("source " .. vim.fn.stdpath("config") .. "/lua/config/keymaps.lua")
  vim.notify("Keymaps reloaded")
end, { desc = "Reload keymaps" })

map({ "n" }, "<leader>rl", "<cmd>Lazy sync<cr>", { desc = "Lazy sync plugins" })
map({ "n" }, "<leader>ct", function()
  vim.cmd("split | terminal tsc --noEmit")
end, { desc = "TypeScript type check" })

map({ "n", "i", "v" }, "<F1>", "<nop>", { desc = "Disabled" })
map({ "n" }, "<F2>", "ggVG", { desc = "Select all" })

map({ "n", "o", "x" }, "<C-`>", function()
  Snacks.terminal()
end, { desc = "Toggle Terminal" })

-- Copy entire file contents to clipboard
map({ "n" }, "<C-S-p>", function()
  -- Save current cursor position
  local cursor_pos = vim.fn.getpos(".")

  -- Select all content and yank to clipboard
  vim.cmd('normal! ggVG"+y')

  -- Restore cursor position
  vim.fn.setpos(".", cursor_pos)

  -- Get file info for notification
  local filename = vim.fn.expand("%:t")
  local line_count = vim.fn.line("$")
  vim.notify(string.format("File copied to clipboard: %s (%d lines)", filename, line_count))
end, { desc = "Copy file contents to clipboard" })
-- Visual mode treesitter text objects (explicit mappings)
map({ "x", "o" }, "rf", function()
  require("nvim-treesitter.textobjects.select").select_textobject("@function.inner", "textobjects")
end, { desc = "Select inner function" })

map({ "x", "o" }, "tf", function()
  require("nvim-treesitter.textobjects.select").select_textobject("@function.outer", "textobjects")
end, { desc = "Select outer function" })

map({ "x", "o" }, "rc", function()
  require("nvim-treesitter.textobjects.select").select_textobject("@class.inner", "textobjects")
end, { desc = "Select inner class" })

map({ "x", "o" }, "tc", function()
  require("nvim-treesitter.textobjects.select").select_textobject("@class.outer", "textobjects")
end, { desc = "Select outer class" })

map({ "x", "o" }, "Re", function()
  require("nvim-treesitter.textobjects.select").select_textobject("@element.inner", "textobjects")
end, { desc = "Select inner JSX element" })

map({ "x", "o" }, "Te", function()
  require("nvim-treesitter.textobjects.select").select_textobject("@element.outer", "textobjects")
end, { desc = "Select around JSX element" })

map({ "x", "o" }, "Rh", function()
  require("nvim-treesitter.textobjects.select").select_textobject("@tag.inner", "textobjects")
end, { desc = "Select inner HTML tag" })

map({ "x", "o" }, "Th", function()
  require("nvim-treesitter.textobjects.select").select_textobject("@tag.outer", "textobjects")
end, { desc = "Select around HTML tag" })
map({ "n", "o", "v" }, "r", "i", { desc = "O/V mode: inner (i)" })
map({ "n", "o", "v" }, "t", "a", { desc = "O/V mode: a/an (a)" })

map({ "v" }, "s", "<Plug>(nvim-surround-visual)", { desc = "Surround visual selection" })
map({ "o", "v" }, "R", "r", { desc = "Replace" })
map({ "o", "v" }, "rd", "iw", { desc = "Inner word" })
map({ "o", "v" }, "td", "aw", { desc = "Around word" })
-- Operator-pending mode mappings to help with nvim-surround
-- These allow your r/t mappings to work in operator-pending mode
map({ "v" }, "rd", "iw", { desc = "Inner word (visual)" })
map({ "v" }, "td", "aw", { desc = "Around word (visual)" })
-- rf and tf handled by treesitter-textobjects
map({ "o" }, "r(", "i(", { desc = "Inner parentheses (for nvim-surround)" })
map({ "o" }, "r)", "i)", { desc = "Inner parentheses (for nvim-surround)" })
map({ "o" }, "r[", "i[", { desc = "Inner brackets (for nvim-surround)" })
map({ "o" }, "r]", "i]", { desc = "Inner brackets (for nvim-surround)" })
map({ "o" }, "r{", "i{", { desc = "Inner braces (for nvim-surround)" })
map({ "o" }, "r}", "i}", { desc = "Inner braces (for nvim-surround)" })
map({ "o" }, 'r"', 'i"', { desc = "Inner quotes (for nvim-surround)" })
map({ "o" }, "r'", "i'", { desc = "Inner single quotes (for nvim-surround)" })
map({ "o" }, "t(", "a(", { desc = "Around parentheses (for nvim-surround)" })
map({ "o" }, "t)", "a)", { desc = "Around parentheses (for nvim-surround)" })
map({ "o" }, "t[", "a[", { desc = "Around brackets (for nvim-surround)" })
map({ "o" }, "t]", "a]", { desc = "Around brackets (for nvim-surround)" })
map({ "o" }, "t{", "a{", { desc = "Around braces (for nvim-surround)" })
map({ "o" }, "t}", "a}", { desc = "Around braces (for nvim-surround)" })
map({ "o" }, 't"', 'a"', { desc = "Around quotes (for nvim-surround)" })
map({ "o" }, "t'", "a'", { desc = "Around single quotes (for nvim-surround)" })

-- TypeScript Go to Source Definition with fallback to regular definition
override_map("n", "<leader>cx", function()
  vim.notify("Go to source definition triggered", vim.log.levels.INFO)

  local clients = vim.lsp.get_clients({ bufnr = 0 })
  vim.notify("Found " .. #clients .. " LSP clients", vim.log.levels.INFO)

  local ts_client = nil

  -- Find typescript-tools client specifically
  for _, client in ipairs(clients) do
    vim.notify("Client found: " .. client.name, vim.log.levels.INFO)
    if client.name == "typescript-tools" then
      ts_client = client
      break
    end
  end

  if not ts_client then
    vim.notify("TypeScript Tools not attached", vim.log.levels.WARN)
    vim.lsp.buf.definition()
    return
  end

  vim.notify("Using typescript-tools client", vim.log.levels.INFO)
  local position_params = vim.lsp.util.make_position_params(0, ts_client.offset_encoding, 0)

  vim.lsp.buf_request(0, "workspace/executeCommand", {
    command = "typescript.goToSourceDefinition",
    arguments = { position_params.textDocument.uri, position_params.position },
  }, function(err, result, ctx, config)
    if err then
      vim.notify("Error: " .. tostring(err), vim.log.levels.ERROR)
      return
    end

    if not result or (type(result) == "table" and #result == 0) then
      vim.notify("No source definition found, trying regular definition", vim.log.levels.INFO)
      -- First try gd (floating window), then fall back to opening in new buffer
      vim.lsp.buf.definition({
        on_list = function(options)
          if options.items and #options.items > 0 then
            local item = options.items[1]
            vim.cmd("edit " .. item.filename)
            vim.api.nvim_win_set_cursor(0, { item.lnum, item.col - 1 })
          end
        end,
      })
      return
    end

    local location = result
    if type(result) == "table" and result[1] then
      location = result[1]
    end

    vim.lsp.util.jump_to_location(location, "utf-8")
  end)
end, { desc = "Go to source definition (fallback to definition)" })

-- Grug-far search within range
map({ "n", "x" }, "<leader>sR", function()
  require("grug-far").open({ visualSelectionUsage = "operate-within-range" })
end, { desc = "Search within range" })

map({ "n" }, "<C-a>", "<cmd>bprevious<CR>", { desc = "Previous buffer" })
map({ "n" }, "<C-e>", "<cmd>bnext<CR>", { desc = "Next buffer" })
-- Smart buffer delete function
local function smart_buffer_delete()
  local bufs = vim.tbl_filter(function(buf)
    return vim.api.nvim_buf_is_loaded(buf) and vim.bo[buf].buflisted
  end, vim.api.nvim_list_bufs())

  if #bufs <= 1 then
    vim.cmd("bd")
    require("snacks").dashboard()
  else
    vim.cmd("bd")
  end
end

map({ "n" }, "<C-w>w", smart_buffer_delete, { desc = "Close buffer" })
map({ "n" }, "<C-w>o", "<cmd>%bd|e#<CR>", { desc = "Close all buffers but current" })
map({ "n" }, "<leader>bd", smart_buffer_delete, { desc = "Delete Buffer" })
