;; kulala.nvim — HTTP client for Neovim
{1 "mistweaverco/kulala.nvim"
 :dev true
 :ft ["http" "rest"]
 :cmd ["Kulala"]
 :keys
 [{1 "<leader>at" 2 (fn [] ((. (require :kulala) :run)))                  :desc "Send request"}
  {1 "<leader>aT" 2 (fn [] ((. (require :kulala) :run-all)))              :desc "Send all requests"}
  {1 "<leader>ar" 2 (fn [] ((. (require :kulala) :scratchpad)))           :desc "Open scratchpad"}
  {1 "<leader>ao" 2 (fn [] ((. (require :kulala) :open_openapi_explorer)))
   :ft ["http" "rest"] :desc "OpenAPI explorer (spec ref under cursor)"}]
 :opts {:global_keymaps false
        :keymaps {}
        :openapi_panel {:win_opts {:wo {:winbar ""}}}
        :openapi_panel_keymaps {"Edit try it out" false
                                "Load from file" false
                                "Refresh" false}}
 :config
 (fn [_ opts]
   ((. (require :kulala) :setup) opts)
   (vim.api.nvim_create_user_command
    :Kulala
    (fn [args]
      (let [kulala (require :kulala)
            action (if (= args.args "") "run" args.args)]
        (case action
          "run"                 (kulala.run)
          "run-all"             ((. kulala :run-all))
          "scratchpad"          (kulala.scratchpad)
          "openapi"             (kulala.open_openapi_explorer)
          "clear-openapi-cache" (kulala.clear_openapi_schema_cache)
          _ (vim.notify (.. "Kulala: unknown action " action) vim.log.levels.ERROR))))
    {:nargs "?"
     :complete (fn [] ["run" "run-all" "scratchpad" "openapi" "clear-openapi-cache"])
     :desc "Kulala HTTP client"}))}
