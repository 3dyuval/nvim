;; :SchemaStore — Snacks picker over the SchemaStore catalog.
;;
;; `require('schemastore').json.schemas()` ships the catalog (name/description/
;; url/fileMatch) locally, but NOT the schema bodies. So we list from the local
;; catalog and fetch each schema document from its url on demand, caching the
;; body to ~/.cache/nvim/schemastore/ so every url is fetched at most once ever.

(local M {})

(local cache-dir (.. (vim.fn.stdpath :cache) "/schemastore"))

;; in-memory body cache for the current session (avoids re-reading disk)
(local mem {})

(fn ensure-cache-dir []
  (when (= 0 (vim.fn.isdirectory cache-dir))
    (vim.fn.mkdir cache-dir :p)))

;; deterministic, filesystem-safe cache filename for a url
(fn cache-path [url]
  (.. cache-dir "/" (vim.fn.sha256 url) ".json"))

(fn read-file [path]
  (let [(fd _) (io.open path :r)]
    (when fd
      (let [data (fd:read :*a)]
        (fd:close)
        data))))

(fn write-file [path data]
  (let [(fd _) (io.open path :w)]
    (when fd
      (fd:write data)
      (fd:close))))

;; Return cached body (mem → disk) or nil if not yet fetched.
(fn cached-body [url]
  (or (. mem url)
      (let [disk (read-file (cache-path url))]
        (when disk
          (tset mem url disk)
          disk))))

;; Format JSON body for display: prefer jq (stable indentation), else raw text.
(fn format-body [text]
  (if (= 1 (vim.fn.executable :jq))
      (let [out (vim.fn.system [:jq :.] text)]
        (if (= 0 vim.v.shell_error) out text))
      text))

;; Render a body string into the preview buffer as json.
(fn show-body [ctx text]
  (ctx.preview:reset)
  (ctx.preview:set_lines (vim.split (format-body text) "\n"))
  (ctx.preview:highlight {:ft :json}))

;; Render the metadata header (used while fetching / on error).
(fn show-meta [ctx item status]
  (ctx.preview:reset)
  (let [fm (. item :_fileMatch)
        lines [(.. "# " (or item._name item.text))
               ""
               (.. "url:         " item._url)
               (.. "fileMatch:   "
                   (if (and fm (> (length fm) 0))
                       (table.concat fm ", ")
                       "—"))
               ""]]
    (when item._desc
      (table.insert lines item._desc)
      (table.insert lines ""))
    (table.insert lines (.. "── " status " ──"))
    (ctx.preview:set_lines lines)
    (ctx.preview:highlight {:ft :markdown})))

;; Async fetch a url, cache it, and re-render IF the user is still on it.
(fn fetch-async [ctx item]
  (let [url item._url
        picker ctx.picker]
    (vim.system
      [:curl :-sSL :--max-time :15 url]
      {:text true}
      (fn [res]
        (vim.schedule
          (fn []
            (let [current (picker:current {:resolve false})
                  still-here? (and current (= current._url url))]
              (if (and (= 0 res.code) res.stdout (not= res.stdout ""))
                  (do
                    (ensure-cache-dir)
                    (write-file (cache-path url) res.stdout)
                    (tset mem url res.stdout)
                    (when still-here? (show-body ctx res.stdout)))
                  (when still-here?
                    (show-meta ctx item
                               (.. "fetch failed (curl " res.code ")")))))))))))

;; Custom preview: cached → render now; else show meta + kick off async fetch.
(fn preview [ctx]
  (let [item ctx.item
        body (cached-body item._url)]
    (if body
        (show-body ctx body)
        (do
          (show-meta ctx item "fetching…")
          (fetch-async ctx item)))))

(fn M.open []
  (let [schemas ((. (require :schemastore) :json :schemas))
        items []]
    (each [_ s (ipairs schemas)]
      (table.insert items
                    ;; The matcher only fuzzy-matches `item.text`, so fold the
                    ;; url + description into it for searchability. `_name` keeps
                    ;; the clean label for display via the custom `format`.
                    {:text (.. (or s.name "") " " (or s.url "")
                               " " (or s.description ""))
                     :_name s.name
                     :_url s.url
                     :_desc s.description
                     :_fileMatch s.fileMatch}))
    ((. (require :snacks) :picker :pick)
     {: items
      :title "SchemaStore"
      :format (fn [item _picker]
                [[(or item._name item.text) :SnacksPickerLabel]
                 [(.. "  " (or item._url "")) :SnacksPickerComment]])
      : preview
      :layout {:preset :default}
      :confirm (fn [picker item]
                 ;; <CR>: open the fetched schema in a real scratch buffer
                 (picker:close)
                 (let [body (cached-body item._url)]
                   (when body
                     (vim.cmd "enew")
                     (vim.api.nvim_buf_set_lines 0 0 -1 false
                                                 (vim.split (format-body body) "\n"))
                     (set vim.bo.filetype :json)
                     (set vim.bo.buftype :nofile)
                     (vim.api.nvim_buf_set_name 0
                                                (.. "schemastore://"
                                                    (or item._name item.text))))))})))

(fn M.setup []
  (vim.api.nvim_create_user_command :SchemaStore
    (fn [_] (M.open))
    {:desc "Browse SchemaStore catalog (fetches + caches schema bodies)"}))

M
