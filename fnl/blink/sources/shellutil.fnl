;; Shared utilities for shell blink sources

;; Match `cmd` as a whole word in `text`, so e.g. "jq" does not match inside
;; "yq" or "myjq". %f[%w]/%f[%W] are frontier patterns marking word boundaries.
(fn has-command? [text cmd]
  (not= nil (text:match (.. "%f[%w]" cmd "%f[%W]"))))

;; Walk up the treesitter tree looking for a command/pipeline node whose text
;; contains `cmd` as a whole word. Returns true/false, tail-recursive.
(fn node-matches? [node cmd bufnr]
  (when node
    (if (and (or (= (node:type) :command) (= (node:type) :pipeline))
             (let [text (vim.treesitter.get_node_text node bufnr)]
               (and text (has-command? text cmd) true)))
        true
        (node-matches? (node:parent) cmd bufnr))))

;; Scan backwards from `row` while lines are line-continuations (end in \ or |),
;; checking each for `cmd`. Returns true on the first match.
(fn scan-back? [bufnr row cmd]
  (let [floor (math.max 0 (- row 20))]
    (fn loop [i]
      (if (< i floor)
          false
          (let [prev (or (. (vim.api.nvim_buf_get_lines bufnr i (+ i 1) false) 1) "")]
            (if (has-command? prev cmd)
                true
                (not (prev:match "[\\|]%s*$")) ; stop: not a continuation line
                false
                (loop (- i 1))))))
    (loop (- row 1))))

;; Check if the cursor is inside a command invocation of `cmd` using treesitter.
;; Falls back to line scanning if no treesitter parser is available.
;; Matches `cmd` on a word boundary so similar names (jq/yq) don't cross-trigger.
(fn in-command [ctx cmd]
  (let [bufnr (vim.api.nvim_get_current_buf)
        row (- (. ctx.cursor 1) 1)
        col (. ctx.cursor 2)
        (ok node) (pcall vim.treesitter.get_node {: bufnr :pos [row col]})]
    (or (and ok (node-matches? node cmd bufnr) true)
        (has-command? ctx.line cmd)
        (scan-back? bufnr row cmd))))

{:in_command in-command}
