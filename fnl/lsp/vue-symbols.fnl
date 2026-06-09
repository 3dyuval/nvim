;; Vue <script>/<script setup> symbols via the injected TypeScript tree.
;; Volar 3.x hybrid LSP returns no usable document symbols for .vue, and the
;; standard treesitter pickers only read the primary `vue` tree — so we descend
;; into the injected ts/js child tree and pull top-level declarations ourselves.

(local query-src "(lexical_declaration (variable_declarator name: (identifier) @name))
   (function_declaration name: (identifier) @name)
   (class_declaration name: (type_identifier) @name)")

(fn gather-symbols [buf]
  (let [(ok parser) (pcall vim.treesitter.get_parser buf)
        items []]
    (when (and ok parser)
      (parser:parse true)
      (each [lang child (pairs (parser:children))]
        (when (or (= lang :typescript) (= lang :tsx) (= lang :javascript))
          (let [(qok query) (pcall vim.treesitter.query.parse lang query-src)]
            (when qok
              (each [_ tree (ipairs (child:trees))]
                (each [_ node (query:iter_captures (tree:root) buf 0 -1)]
                  (let [(srow scol) (node:range)]
                    (table.insert items
                                  {:text (vim.treesitter.get_node_text node buf)
                                   : buf
                                   :pos [(+ srow 1) scol]})))))))))
    items))

(fn pick [layout]
  (let [items (gather-symbols (vim.api.nvim_get_current_buf))]
    ((. (require :snacks) :picker :pick) {: items
                                          :format :text
                                          :layout (or layout :bottom)
                                          :title "Vue script symbols"})))

{:symbols gather-symbols : pick}

