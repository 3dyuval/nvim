;; kulala.nvim — HTTP client for Neovim
{1 "mistweaverco/kulala.nvim"
 :ft ["http" "rest"]
 :cmd ["Kulala"]
 :keys
 [{1 "<leader>at" 2 (fn [] ((. (require :kulala) :run)))        :desc "Send request"}
  {1 "<leader>aT" 2 (fn [] ((. (require :kulala) :run-all)))    :desc "Send all requests"}
  {1 "<leader>ar" 2 (fn [] ((. (require :kulala) :scratchpad))) :desc "Open scratchpad"}]
 :opts {:global_keymaps false
        :keymaps {}}
 :config
 (fn [_ opts]
   ((. (require :kulala) :setup) opts)
   ;; :Kulala {run|run-all|scratchpad} — kulala ships no user command, so
   ;; define one here (also the :cmd lazy-load trigger above).
   (vim.api.nvim_create_user_command
    :Kulala
    (fn [args]
      (let [kulala (require :kulala)
            action (if (= args.args "") "run" args.args)]
        (case action
          "run"        (kulala.run)
          "run-all"    ((. kulala :run-all))
          "scratchpad" (kulala.scratchpad)
          _ (vim.notify (.. "Kulala: unknown action " action) vim.log.levels.ERROR))))
    {:nargs "?"
     :complete (fn [] ["run" "run-all" "scratchpad"])
     :desc "Kulala HTTP client"}))}
