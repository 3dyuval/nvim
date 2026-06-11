;; hover.nvim provider: offline MDN descriptions for HTML elements/attributes
;; and links for JS globals. Data is generated (see hover-mdn/gen.mjs) into
;; mdn-data.json in the VSCode custom-data schema — drop-in as a customData
;; source for an html-ls later. Enabled for HTML- and JS-family filetypes; when
;; the word under the cursor isn't a known element/attr/global, execute returns
;; done(false) so hover skips to the next provider (the LSP), showing nothing.

(local html-fts {:html true :vue true :svelte true :htmldjango true :php true})
(local js-fts {:javascript true :javascriptreact true :typescript true
               :typescriptreact true :vue true})

;; Resolve mdn-data.json via the runtimepath (the file ships under
;; lua/hover-mdn/ in this config). Avoids the debug.getinfo "@"-prefix path
;; corruption and works regardless of where the config dir lives.
(local data-path
       (or (. (vim.api.nvim_get_runtime_file "lua/hover-mdn/mdn-data.json" false) 1)
           (.. (vim.fn.stdpath :config) "/lua/hover-mdn/mdn-data.json")))

(local empty {:tags [] :globalAttributes [] :jsGlobals []})
(var raw nil)
(fn load-json []
  (when (not raw)
    (let [(ok lines) (pcall vim.fn.readfile data-path)]
      (if (and ok (= (type lines) :table))
          (let [(ok2 decoded) (pcall vim.json.decode (table.concat lines "\n"))]
            (set raw (if (and ok2 (= (type decoded) :table)) decoded empty)))
          (do
            (vim.notify (.. "hover-mdn: cannot read " data-path) vim.log.levels.WARN)
            (set raw empty)))))
  raw)

;; Build name -> entry maps from the custom-data arrays, lazily.
(var maps nil)
(fn description [entry]
  (let [d entry.description]
    (if (= (type d) :table) d.value
        (= (type d) :string) d
        nil)))
(fn ref-url [entry]
  (let [r (and entry.references (. entry.references 1))]
    (and r r.url)))
(fn index [arr]
  (let [m {}]
    (each [_ e (ipairs (or arr []))]
      (tset m e.name e))
    m))
(fn get-maps []
  (when (not maps)
    (let [j (load-json)]
      (set maps {:elements (index j.tags)
                 :attributes (index j.globalAttributes)
                 :js (index j.jsGlobals)})))
  maps)

;; Find the element name when the cursor sits on/inside a tag.
(fn element-name [bufnr]
  (let [(ok node) (pcall vim.treesitter.get_node {:bufnr bufnr})]
    (var name nil)
    (when (and ok node)
      (var n node)
      (while (and n (not name))
        (let [t (n:type)]
          (when (or (t:find "element") (t:find "tag") (t:find "component"))
            (each [child (n:iter_children) &until name]
              (let [ct (child:type)]
                (when (or (= ct :tag_name) (ct:find "name"))
                  (set name (vim.treesitter.get_node_text child bufnr)))))))
        (set n (n:parent))))
    (or name (vim.fn.expand "<cword>"))))

(fn lines-for [entry title]
  (let [out [(.. "# " title)]
        desc (description entry)
        url (ref-url entry)]
    (when desc (table.insert out "") (table.insert out desc))
    (when url (table.insert out "") (table.insert out (.. "[MDN](" url ")")))
    out))

;; Returns [entry title] (or nil). Plain table, not multi-value (and/or only
;; propagate the first value through short-circuiting in Fennel).
(fn lookup [bufnr]
  (let [m (get-maps)
        ft (. vim.bo bufnr :filetype)
        word (vim.fn.expand "<cword>")
        el (when (. html-fts ft) (element-name bufnr))]
    (if (and el (. m.elements el)) [(. m.elements el) (.. "<" el ">")]
        (and (. html-fts ft) (. m.elements word)) [(. m.elements word) (.. "<" word ">")]
        (and (. html-fts ft) (. m.attributes word)) [(. m.attributes word) (.. word " (attribute)")]
        (and (or (. html-fts ft) (. js-fts ft)) (. m.js word)) [(. m.js word) word]
        nil)))

;; --- hover.nvim provider table ---
{:name :MDN
 :priority 175
 :enabled (fn [bufnr]
            (let [ft (. vim.bo bufnr :filetype)]
              (and (or (. html-fts ft) (. js-fts ft)) true)))
 :execute (fn [params done]
            (let [hit (lookup params.bufnr)]
              (if hit
                  (done {:lines (lines-for (. hit 1) (. hit 2)) :filetype :markdown})
                  (done false))))}
