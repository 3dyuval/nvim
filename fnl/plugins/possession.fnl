;; possession.nvim — named + cwd sessions. Replaces auto-session/persistence.
;; autosave the cwd session on quit; autoload this cwd's session on startup.
;; Picker lives in session.picker (snacks, over possession.session.list).
;; persistence.nvim is disabled in lua/plugins/lazyvim-config.lua.
;; possession does NOT save vim.g globals like persistence did, so the hooks
;; below persist the specific uppercase globals we relied on (FFFLayout,
;; AiCommitLastSettings) via user_data.

(local persisted-globals [:FFFLayout :AiCommitLastSettings])
{1 "jedrzejboczar/possession.nvim"
 :dependencies ["nvim-lua/plenary.nvim"]
 :lazy false
 :config (fn []
            ;; Only autosave the cwd session when at least one real (named,
            ;; listed, normal) file buffer is open — prevents an empty dashboard
            ;; quit from clobbering a good session with nothing.
            (local has-real-buffer?
              (fn []
                (var found false)
                (each [_ b (ipairs (vim.api.nvim_list_bufs)) &until found]
                  (when (and (vim.api.nvim_buf_is_loaded b)
                             (. (. vim.bo b) :buflisted)
                             (= (. (. vim.bo b) :buftype) "")
                             (not= (vim.api.nvim_buf_get_name b) ""))
                    (set found true)))
                found))
            ((. (require :possession) :setup)
             {:autoload :auto_cwd
              ;; autoload sets an active session, so autosave goes through the
              ;; `current` branch — it must be enabled (guarded) or nothing saves.
              :autosave {:current has-real-buffer?
                         :cwd has-real-buffer?
                         :on_load true
                         :on_quit true}
              :commands {:save "PossessionSave"
                         :load "PossessionLoad"
                         :save_cwd "PossessionSaveCwd"
                         :load_cwd "PossessionLoadCwd"
                         :delete "PossessionDelete"
                         :list "PossessionList"
                         :list_cwd "PossessionListCwd"}
              :hooks {:before_save (fn [_name]
                                     (let [data {}]
                                       (each [_ g (ipairs persisted-globals)]
                                         (tset data g (. vim.g g)))
                                       data))
                      :before_load (fn [_name user-data]
                                     (when user-data
                                       (each [_ g (ipairs persisted-globals)]
                                         (when (not= (. user-data g) nil)
                                           (tset vim.g g (. user-data g)))))
                                     user-data)
                      ;; :mksession-restored buffers don't fire FileType/BufReadPost,
                      ;; so ftplugin/treesitter/LSP never attach. Re-detect filetype
                      ;; per real buffer to trigger those (cascades to TS + LSP).
                      :after_load (fn [_name _user-data]
                                    (vim.schedule
                                      (fn []
                                        (each [_ b (ipairs (vim.api.nvim_list_bufs))]
                                          (when (and (vim.api.nvim_buf_is_loaded b)
                                                     (= (. (. vim.bo b) :buftype) "")
                                                     (not= (vim.api.nvim_buf_get_name b) ""))
                                            (vim.api.nvim_buf_call b
                                              (fn [] (vim.cmd "filetype detect"))))))))}}))}
