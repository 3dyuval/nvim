;; blink.cmp source for Conventional Commit types and scopes.
;;
;; Values come from the buffer vars `b:commitlint_types` / `b:commitlint_scopes`,
;; populated by the FileType gitcommit autocmd (see fnl/config/autocmds.fnl),
;; which shells out to scripts/commitlint.sh.
;;
;; Context gating on the subject line `type(scope): subject`:
;;   - inside an unclosed `(` ............... offer scopes
;;   - at the start, before any `(` or `:` .. offer types
;;   - anywhere else ........................ nothing

;; Build blink items from a list of plain string values.
;; blink renders a per-item `kind_name`/`kind_icon`/`kind_hl` (see
;; blink.cmp render/context.lua), so we give types and scopes their own custom
;; kind label, nerd-font glyph, and highlight instead of the generic Enum icon.
(fn build-items [labels spec]
  (let [out []]
    (each [_ v (ipairs (or labels []))]
      (table.insert out {:label v
                         :detail spec.detail
                         :kind_name spec.kind_name
                         :kind_icon spec.icon
                         :kind_hl spec.hl}))
    out))

(local type-spec {:kind_name "Type" :icon "" :hl "Function"
                  :detail "commit type"})
(local scope-spec {:kind_name "Scope" :icon "" :hl "String"
                   :detail "commit scope"})

(local M {})

(fn M.new []
  (setmetatable {} {:__index M}))

;; `(` opens the scope; `,` separates multiple scopes. Declaring these makes
;; blink query this source the moment they're typed (they aren't word chars,
;; so the keyword trigger alone wouldn't fire the menu inside `feat(`).
(fn M.get_trigger_characters [self]
  ["(" ","])

(fn M.get_completions [self ctx callback]
  ;; ctx.line is the WHOLE line; ctx.cursor is [row col] with col 0-indexed.
  ;; Gate on the text up to the cursor so `feat(|): subject` still counts as
  ;; scope context (text after the cursor must not break the match).
  (let [line (or ctx.line "")
        col (or (?. ctx.cursor 2) (length line))
        before (line:sub 1 col)
        bufnr (vim.api.nvim_get_current_buf)
        finish (fn [items]
                 (callback {:is_incomplete_forward false
                            :is_incomplete_backward false
                            :items items}))]
    (if
      ;; Scope context: cursor sits inside the `(...)` after the type, e.g.
      ;; `feat(`, `feat(ls`, `fix(a,b`. No `)` between the paren and cursor.
      (before:match "^%s*[%w_/-]*%([^)]*$")
      (finish (build-items (. vim.b bufnr :commitlint_scopes) scope-spec))
      ;; Type context: line start, only a partial word before the cursor.
      (before:match "^%s*[%w_/-]*$")
      (finish (build-items (. vim.b bufnr :commitlint_types) type-spec))
      ;; Otherwise: no completions.
      (finish []))))

M
