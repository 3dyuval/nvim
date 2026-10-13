;; Jump between nvim-mcp virtual-text annotations. The MCP server
;; (uvx nvim-mcp, add_virtual_text tool) writes every annotation as an
;; extmark in a single dedicated namespace, 'mcp_virtual_text' (see the
;; plugin's lua.py VIRTUAL_TEXT block). We read that namespace and move the
;; cursor between marks. This is NOT LSP diagnostics (those are ]d / [d).

(local M {})

(fn mark-rows []
  "Sorted, de-duplicated 0-indexed rows of every mcp_virtual_text extmark in
  the current buffer. create_namespace is idempotent — returns the existing id."
  (let [ns (vim.api.nvim_create_namespace :mcp_virtual_text)
        buf (vim.api.nvim_get_current_buf)
        marks (vim.api.nvim_buf_get_extmarks buf ns 0 -1 {})
        seen {}
        rows []]
    (each [_ m (ipairs marks)]
      (let [r (. m 2)]
        (when (not (. seen r))
          (tset seen r true)
          (table.insert rows r))))
    (table.sort rows)
    rows))

(fn jump [dir]
  (let [rows (mark-rows)]
    (when (> (length rows) 0)
      (let [cur (- (vim.fn.line ".") 1)]
        (var target nil)
        (if (= dir :next)
            (each [_ r (ipairs rows)]
              (when (and (> r cur) (= target nil))
                (set target r)))
            (each [_ r (ipairs rows)]
              (when (< r cur)
                (set target r))))
        (when target
          (vim.api.nvim_win_set_cursor 0 [(+ target 1) 0]))))))

(fn M.next [] (jump :next))
(fn M.prev [] (jump :prev))

M
