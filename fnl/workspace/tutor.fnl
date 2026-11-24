;; :Tutor is a bundled runtime plugin, but lazy.nvim sets loadplugins=false so
;; $VIMRUNTIME/plugin/tutor.vim never sources and the command never registers.
;; Define a stub :Tutor that sources the real plugin on first use, deletes
;; itself, then delegates to the now-defined tutor#TutorCmd command.
(local M {})

(fn M.setup []
  (vim.api.nvim_create_user_command :Tutor
    (fn [opts]
      (vim.api.nvim_del_user_command :Tutor)
      (vim.cmd "source $VIMRUNTIME/plugin/tutor.vim")
      (vim.cmd (.. "Tutor " opts.args)))
    {:nargs "?"
     :complete (fn [] [])
     :desc "Open the Neovim tutor (lazy-sources the runtime plugin)"}))

(M.setup)

M
