;; yazi.nvim — nvim is home base; pop yazi open on demand, picks open as buffers.
{1 "mikavilpas/yazi.nvim"
 :dependencies [{1 "nvim-lua/plenary.nvim" :lazy true}]
 :event :VeryLazy
 ;; <leader>ff lives in fnl/config/keymaps/pickers.fnl; keep these for lazy-loading.
 :keys [{1 :<leader>- 2 "<cmd>Yazi<cr>" :mode [:n :v] :desc "Yazi at current file"}
        {1 :<leader>cw 2 "<cmd>Yazi cwd<cr>" :desc "Yazi in working dir"}]
 :opts {;; Take over :edit <dir> so opening a directory launches yazi (replaces netrw).
        :open_for_directories true
        ;; Keep nvim's cwd in sync with where you land in yazi.
        :change_neovim_cwd_on_close true
        :floating_window_scaling_factor 0.9
        :keymaps {:show_help :<f1>}
        ;; Use snacks.nvim (already installed) for grep-from-yazi results.
        :integrations {:grep_in_directory :snacks.picker
                       :grep_in_selected_files :snacks.picker}}
 :init (fn []
         ;; Let yazi.nvim own directory-opening instead of netrw.
         (set vim.g.loaded_netrwPlugin 1))}
