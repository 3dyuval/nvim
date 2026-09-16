;; nvim-surround — Graphite layout. Add ys / delete ds / change cs; visual
;; trigger is `s` (enter visual with native v/V, select, then s). r=inner &
;; t=around textobjects, so the default alias r=] is removed. Custom surrounds:
;; markdown (* _ ~), ` code fences (lang prompt), treesitter finds (tf/rf/tc/
;; rc/tp/rp/tl/rl/ts/rs/tt/rt), and `i` for an arbitrary/tag delimiter.
(local M {})

;; Each entry disables surround for a buffer when it returns true.
(local disable-surround
  [(fn [] (not vim.bo.modifiable))])

(fn M.get_input [prompt]
  ((. (require :nvim-surround.config) :get_input) prompt))

(fn M.get_selection [args]
  (if args.motion
      ((. (require :nvim-surround.config) :get_selection) {:motion args.motion})
      args.query
      (let [(ok ts-queries) (pcall require :nvim-treesitter-textobjects.queries)]
        (if (not ok)
            (do (vim.notify "nvim-treesitter-textobjects not available"
                            vim.log.levels.WARN)
                nil)
            (let [bufnr (vim.api.nvim_get_current_buf)
                  node (ts-queries.get_node_at_cursor bufnr args.query.capture)]
              (if (not node)
                  nil
                  (let [(start-row start-col end-row end-col) (node:range)]
                    {:left {:first_pos [(+ start-row 1) (+ start-col 1)]}
                     :right {:last_pos [(+ end-row 1) end-col]}})))))))

(fn ts-find [capture]
  {:find (fn [] (M.get_selection {:query {:capture capture}}))})

;; Mirror a delimiter string into its closing form, e.g. "<'{" -> "}'>".
(local mirror-pairs
  {"(" ")" ")" "(" "[" "]" "]" "["
   "{" "}" "}" "{" "<" ">" ">" "<"})

(fn mirror [input]
  (var right "")
  (for [i (length input) 1 -1]
    (let [char (input:sub i i)]
      (set right (.. right (or (. mirror-pairs char) char)))))
  right)

(fn custom-delimiter []
  (let [input (M.get_input "Enter delimiter pair (left/right or tag): ")]
    (when input
      (let [opening-tag (input:match "^<([^/>]+)>?$")]
        (if opening-tag
            (let [tag-name (opening-tag:match "^([^%s>]+)")]
              [[(.. "<" opening-tag ">")] [(.. "</" tag-name ">")]])
            [[input] [(mirror input)]])))))

{1 "kylechui/nvim-surround"
 :event "VeryLazy"
 :dependencies ["nvim-treesitter/nvim-treesitter-textobjects"]
 ;; Must be set before plugin/nvim-surround.lua binds defaults (reads it at
 ;; load). config/keymaps/surround.fnl re-binds the visual trigger (`s`).
 :init (fn [] (set vim.g.nvim_surround_no_visual_mappings true))
 :opts
 {:surrounds
  ;; Reversed from nvim-surround defaults: opening bracket = tight, closing =
  ;; spaced. So ysiw( -> (hello) and ysiw) -> ( hello ).
  {"(" {:add ["(" ")"]}
   ")" {:add ["( " " )"]}
   "{" {:add ["{" "}"]}
   "}" {:add ["{ " " }"]}
   "[" {:add ["[" "]"]}
   "]" {:add ["[ " " ]"]}
   "<" {:add ["<" ">"]}
   ">" {:add ["< " " >"]}
   "*" {:add ["**" "**"]}
   "_" {:add ["_" "_"]}
   "~" {:add ["~" "~"]}
   "`" {:add (fn []
               (let [lang (M.get_input "Language: ")]
                 (vim.schedule
                   (fn []
                     (let [row (. (vim.api.nvim_win_get_cursor 0) 1)]
                       (vim.api.nvim_win_set_cursor 0 [(+ row 1) 0])
                       (vim.cmd "startinsert"))))
                 [["```" ""] ["" "```"]]))
        :find (fn [] (M.get_selection {:motion "a`"}))
        :delete (fn []
                  ((. (require :nvim-surround.config) :get_selections)
                   {:char "`" :pattern "^(```.-\n)().*(```\n?)()$"}))}
   "tf" (ts-find "@function.outer")
   "rf" (ts-find "@function.inner")
   "tc" (ts-find "@class.outer")
   "rc" (ts-find "@class.inner")
   "tp" (ts-find "@parameter.outer")
   "rp" (ts-find "@parameter.inner")
   "tl" (ts-find "@loop.outer")
   "rl" (ts-find "@loop.inner")
   "ts" (ts-find "@scope")
   "rs" (ts-find "@scope")
   "tt" (ts-find "@tag.outer")
   "rt" (ts-find "@tag.inner")
   "i" {:add custom-delimiter}}
  ;; Single alias: b = any bracket. Adds tight (opening chars: ysiwb -> (hello));
  ;; delete/change match any of ( [ { <. No other aliases.
  :aliases {"b" ["(" "[" "{" "<"]}}
 :config
 (fn [_ opts]
   ;; Patch set_operator_marks to use bang (normal!) so Graphite key remaps
   ;; don't corrupt the g@ motion used to find surround positions.
   (let [buffer (require :nvim-surround.buffer)]
     (set buffer.set_operator_marks
          (fn [motion]
            (let [curpos (buffer.get_curpos)
                  visual-marks [(buffer.get_mark "<") (buffer.get_mark ">")]]
              (buffer.del_marks ["[" "]"])
              (set vim.go.operatorfunc "v:lua.require'nvim-surround.utils'.NOOP")
              (vim.cmd.normal {:args [(.. "g@" motion)] :bang true})
              (buffer.adjust_mark "[")
              (buffer.adjust_mark "]")
              (buffer.set_curpos curpos)
              (buffer.set_mark "<" (. visual-marks 1))
              (buffer.set_mark ">" (. visual-marks 2))))))

   ;; v4 auto-binds default keymaps from plugin/; custom surround keymaps
   ;; (visual `s`/`gS`, which-key groups) live in config/keymaps/surround.fnl.
   ((. (require :nvim-surround) :setup) opts)

   ;; Disable nvim-surround for non-modifiable / special buffers (buffer-local
   ;; deletes only — never touch the global maps).
   (vim.api.nvim_create_autocmd ["BufEnter" "BufWinEnter"]
     {:pattern "*"
      :callback
      (fn []
        (var should-disable false)
        (each [_ cond (ipairs disable-surround) :until should-disable]
          (when (cond) (set should-disable true)))
        (when should-disable
          (each [_ key (ipairs ["s" "gS"])]
            (pcall vim.keymap.set "x" key "<Nop>" {:buffer 0}))
          (each [_ key (ipairs ["ys" "yss" "yS" "ySS" "ds" "cs" "cS"])]
            (pcall vim.keymap.set "n" key "<Nop>" {:buffer 0}))))}))}
