(local M {})

(fn history-file []
  (.. (. ((. (require :grug-far.opts) :getGlobalOptions)) :history :historyDir)
      "/history"))

(fn entries []
  "Parse the grug-far history file into HistoryEntry list, newest first."
  (let [path (history-file)]
    (if (= (vim.fn.filereadable path) 0)
        []
        (let [text (table.concat (vim.fn.readfile path) "\n")
              hist (require :grug-far.history)
              out []]
          (each [_ block (ipairs (vim.split text "\n\n+" {:trimempty true}))]
            (when (block:match "Engine:")
              (table.insert out (hist.getHistoryEntryFromLines (vim.split block "\n")))))
          out))))

(fn M.pick []
  "Snacks picker over all grug-far history entries; select opens prefilled."
  (let [items []]
    (each [i entry (ipairs (entries))]
      (table.insert items
        {:idx i
         :entry entry
         :text (or (and (not= entry.search "") entry.search) entry.paths "(empty)")}))
    (if (= (length items) 0)
        (vim.notify "grug-far: no history yet" vim.log.levels.INFO)
        (Snacks.picker.pick
          {:source "grug_history"
           :items items
           :format (fn [item _]
                     [[item.text :SnacksPickerLabel]
                      [(.. "  " (or item.entry.paths "")) :SnacksPickerComment]])
           :confirm (fn [picker item]
                      (picker:close)
                      (when (and item item.entry)
                        ((. (require :grug-far) :open) {:prefills item.entry})))}))))

M
