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
;; Build one blink item from a value + a {kind_name/icon/hl/detail} spec.
(fn make-item [v spec]
  {:label v
   :detail spec.detail
   :kind_name spec.kind_name
   :kind_icon spec.icon
   :kind_hl spec.hl})

;; Build items from a list of plain string values, all sharing one spec.
(fn build-items [labels spec]
  (let [out []]
    (each [_ v (ipairs (or labels []))]
      (table.insert out (make-item v spec)))
    out))

;; Icons are written as codepoints decoded at runtime so the nerd-font glyphs
;; survive any editing pipeline (typed glyphs get stripped to empty strings).
;; 0xf02b = nf-fa-tag (builtin type), 0xf02c = nf-fa-tags (custom type),
;; 0xf487 = nf-oct-package (scope).
;;
;; Three buckets: builtin types use a different icon/colour from project-custom
;; types; scopes are always project-defined (Conventional Commits has no builtin
;; scope set) so they share one kind.
(local builtin-type-spec
       {:kind_name "BuiltinType" :icon (vim.fn.nr2char 0xf02b) :hl "Function"
        :detail "commit type (builtin)"})
(local custom-type-spec
       {:kind_name "CustomType" :icon (vim.fn.nr2char 0xf02c) :hl "Constant"
        :detail "commit type (custom)"})
(local scope-spec
       {:kind_name "Scope" :icon (vim.fn.nr2char 0xf487) :hl "String"
        :detail "commit scope"})

;; Conventional Commits builtin types; anything else in type-enum is project-custom.
(local builtin-types
       {:feat true :fix true :docs true :style true :refactor true :perf true
        :test true :build true :ci true :chore true :revert true})

;; Build type items, picking the builtin vs custom spec per value.
(fn build-type-items [labels]
  (let [out []]
    (each [_ v (ipairs (or labels []))]
      (table.insert out
                    (make-item v (if (. builtin-types v)
                                     builtin-type-spec
                                     custom-type-spec))))
    out))

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
      (finish (build-type-items (. vim.b bufnr :commitlint_types)))
      ;; Otherwise: no completions.
      (finish []))))

M
