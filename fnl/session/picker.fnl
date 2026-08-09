;; Snacks picker over possession.nvim sessions.
;; Lists sessions via possession.session.list(); confirm loads by name.

(local M {})

(fn build-items []
  "Turn possession.session.list() into snacks picker items."
  (let [(ok session) (pcall require :possession.session)]
    (if (not ok)
        []
        (let [items []]
          (each [_ data (pairs (session.list))]
            (when data.name
              (table.insert items
                {:text data.name
                 :name data.name
                 :cwd data.cwd
                 :file data.cwd})))
          items))))

(fn M.open []
  "Open a Snacks picker listing possession sessions; <CR> loads the session."
  (let [items (build-items)]
    (if (= (length items) 0)
        (vim.notify "No sessions found" vim.log.levels.INFO)
        (Snacks.picker.pick
          {:source "sessions"
           :items items
           :format (fn [item _]
                     [[item.name :SnacksPickerLabel]
                      [(.. "  " (or item.cwd "")) :SnacksPickerComment]])
           :confirm (fn [picker item]
                      (picker:close)
                      (when (and item item.name)
                        ((. (require :possession.session) :load) item.name)))}))))

M
