;; kulala.nvim — HTTP client for Neovim
{1 "mistweaverco/kulala.nvim"
 :dev true
 :ft ["http" "rest"]
 :cmd ["Kulala"]
 :keys
 [{1 "<leader>crr" 2 (fn [] ((. (require :kulala) :run)))                  :desc "Run request"}
  {1 "<leader>cro" 2 (fn [] ((. (require :kulala) :open_openapi_explorer)))
   :ft ["http" "rest"] :desc "OpenAPI explorer"}
  {1 "<leader>cr." 2 (fn [] ((. (require :kulala) :scratchpad)))           :desc "Scratchpad"}
  {1 "<leader>cre" 2 (fn [] ((. (require :kulala) :set_selected_env)))     :desc "Select environment"}
  {1 "<leader>crR" 2 (fn [] ((. (require :kulala) :replay)))               :desc "Replay last request"}
  {1 "<leader>crc" 2 (fn [] ((. (require :kulala) :copy)))                 :desc "Copy as cURL"}
  {1 "<leader>crX" 2 (fn [] ((. (require :kulala) :clear_cached_files)))   :desc "Clear cached files"}]
 :opts {:global_keymaps false
        :kulala_keymaps {"Previous tab" false
                         "Next tab" false}
        :openapi_panel_keymaps {"Toggle fold" false
                                "Edit try it out" false
                                "Load from file" false
                                "Refresh" false
                                "Yank as HTTP"
                                ["Y"
                                 (fn []
                                   ((. (require :kulala.ui.openapi_panel) :yank))
                                   (let [fixed (string.gsub (vim.fn.getreg "+")
                                                            "https?://{host}:{port}" "{{baseUrl}}")]
                                     (vim.fn.setreg "+" fixed)
                                     (vim.fn.setreg "\"" fixed)))]}}
 :config
 (fn [_ opts]
   ((. (require :kulala) :setup) opts)
   (vim.api.nvim_create_autocmd :FileType
     {:pattern ["kulala_openapi" "kulala_ui"]
      :callback (fn [ev]
                  (let [ss (require :smart-splits)
                        dirs {"<C-h>" :move_cursor_left
                              "<C-a>" :move_cursor_down
                              "<C-e>" :move_cursor_up
                              "<C-i>" :move_cursor_right}]
                    (each [key dir (pairs dirs)]
                      (vim.keymap.set :n key (fn [] ((. ss dir)))
                                      {:buffer ev.buf :nowait true :desc "Window nav"}))
                    (when (= (. (. vim.bo ev.buf) :filetype) :kulala_ui)
                      (each [_ key (ipairs ["<C-PageUp>" "<C-PageDown>"])]
                        (vim.keymap.set :n key
                                        (fn [] ((. (require :kulala.ui) :close_kulala_buffer)))
                                        {:buffer ev.buf :nowait true :desc "Close kulala results"})))))})
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
