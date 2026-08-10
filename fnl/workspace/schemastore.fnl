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

;; --- $schema insertion --------------------------------------------------
;;
;; We edit the buffer as text (not via vim.json round-trip) so the user's
;; formatting, key order, and comments survive untouched.

;; Find a top-level `"$schema": "..."` line. Returns (row0 indent) where row0
;; is 0-indexed, or nil if none. Only scans the first ~40 lines — $schema is a
;; leading key by convention.
(fn find-schema-line [lines]
  (var found nil)
  (let [n (math.min (length lines) 40)]
    (for [i 1 n]
      (when (not found)
        (let [l (. lines i)
              (s _ indent) (l:find "^(%s*)\"%$schema\"%s*:")]
          (when s
            (set found [(- i 1) indent]))))))
  found)

;; Find the buffer's opening `{` line (0-indexed) and its indent, so we can
;; insert `$schema` as the first property with correct nesting.
(fn find-open-brace [lines]
  (var found nil)
  (let [n (math.min (length lines) 40)]
    (for [i 1 n]
      (when (not found)
        (let [l (. lines i)
              (s _ indent) (l:find "^(%s*){")]
          (when s
            (set found [(- i 1) indent]))))))
  found)

;; Detect one indent unit from the buffer (first indented line), default 2 sp.
(fn detect-indent [lines]
  (var unit "  ")
  (var done false)
  (each [_ l (ipairs lines) &until done]
    (let [(s) (l:find "^%s+%S")]
      (when s
        (set unit (l:match "^(%s+)"))
        (set done true))))
  unit)

;; Replace an existing $schema line's url in-place, preserving its indentation.
(fn replace-schema [bufnr row indent url]
  (let [line (.. indent "\"$schema\": \"" url "\",")]
    (vim.api.nvim_buf_set_lines bufnr row (+ row 1) false [line])))

;; Insert a new $schema line right after the opening brace, indented one level
;; deeper than the brace.
(fn insert-schema [bufnr brace-row brace-indent unit url]
  (let [line (.. brace-indent unit "\"$schema\": \"" url "\",")]
    (vim.api.nvim_buf_set_lines bufnr (+ brace-row 1) (+ brace-row 1) false
                                [line])))

;; Create a fresh JSON file (prompting for a name) seeded with just $schema.
(fn create-json-file [url]
  (vim.ui.input
    {:prompt "New JSON file: " :default "config.json" :completion :file}
    (fn [name]
      (when (and name (not= name ""))
        (vim.cmd (.. "edit " (vim.fn.fnameescape name)))
        (vim.api.nvim_buf_set_lines 0 0 -1 false
                                    ["{" (.. "  \"$schema\": \"" url "\"") "}"])
        (set vim.bo.filetype :json)))))

;; Smart placement: replace (with confirm) → insert into existing object →
;; create a new file.
(fn apply-schema [url]
  (let [bufnr (vim.api.nvim_get_current_buf)
        ft vim.bo.filetype
        lines (vim.api.nvim_buf_get_lines bufnr 0 -1 false)
        empty? (or (= 0 (length lines))
                   (and (= 1 (length lines)) (= "" (. lines 1))))
        json? (or (= ft :json) (= ft :jsonc))
        existing (find-schema-line lines)]
    (if (and json? existing)
        ;; already has $schema → confirm replacement
        (vim.ui.select [:Replace :Cancel]
          {:prompt (.. "$schema exists. Replace with " url "?")}
          (fn [choice]
            (when (= choice :Replace)
              (replace-schema bufnr (. existing 1) (. existing 2) url))))
        (and json? (not empty?))
        ;; JSON buffer, no $schema → insert after opening brace
        (let [brace (find-open-brace lines)
              unit (detect-indent lines)]
          (if brace
              (insert-schema bufnr (. brace 1) (. brace 2) unit url)
              ;; no brace found (odd) → just prepend a line
              (vim.api.nvim_buf_set_lines bufnr 0 0 false
                                          [(.. "\"$schema\": \"" url "\",")])))
        ;; not a JSON buffer / empty → make a new file
        (create-json-file url))))

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
                 ;; <CR>: place `$schema` intelligently — replace existing,
                 ;; insert into the current JSON object, or create a new file.
                 (picker:close)
                 (when item._url
                   (apply-schema item._url)))})))

(fn M.setup []
  (vim.api.nvim_create_user_command :SchemaStore
    (fn [_] (M.open))
    {:desc "Browse SchemaStore catalog (fetches + caches schema bodies)"}))

M
