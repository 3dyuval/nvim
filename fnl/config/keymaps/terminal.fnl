;; Terminal mode scroll keymaps
;; kitty sends these sequences when ctrl+shift+e/a are pressed inside Neovim
;; (instead of kitty handling scroll_page_up/down itself)
(vim.keymap.set :t "\x1b[101;6u" "<C-\\><C-n><C-u>" {:desc "Scroll up in terminal"})
(vim.keymap.set :t "\x1b[97;6u"  "<C-\\><C-n><C-d>" {:desc "Scroll down in terminal"})