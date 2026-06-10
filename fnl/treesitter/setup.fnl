;; Region-aware indent for .vue: HtmlIndent() handles <template>, but knows
;; nothing about JS braces in <script>, and arborist's treesitter indent returns
;; col 0 in the injected script. So inside <script> we do simple brace logic;
;; everywhere else we defer to HtmlIndent. Wired as `indentexpr` for vue below.
(fn _G.vue_indent [lnum]
  (let [lnum (or lnum vim.v.lnum)]
    (var l (- lnum 1))
    (var found nil)
    (while (and (> l 0) (not found))
      (let [s (vim.fn.getline l)]
        (if (s:find "</script") (set found :out)
            (s:find "<script") (set found :in)))
      (set l (- l 1)))
    (if (not= found :in)
        (vim.fn.HtmlIndent)
        (let [prev (vim.fn.prevnonblank (- lnum 1))]
          (if (= prev 0)
              0
              (let [sw (vim.fn.shiftwidth)]
                (var ind (vim.fn.indent prev))
                (when (: (vim.fn.getline prev) :match "[%({%[]%s*$")
                  (set ind (+ ind sw)))
                (when (: (vim.fn.getline lnum) :match "^%s*[%)}%]]")
                  (set ind (- ind sw)))
                ind))))))

(fn setup []
  (vim.filetype.add {:extension {:ab :amber :heex :heex :kcl :kcl}})
  (vim.api.nvim_create_autocmd :FileType
    {:callback
     (fn [ev]
       (local lang (or (vim.treesitter.language.get_lang ev.match) ev.match))
       (when (and lang (not= lang ""))
         (pcall vim.treesitter.start ev.buf lang)
         (set vim.wo.foldexpr "v:lua.vim.treesitter.foldexpr()")
         ;; deferred so it overrides the html ftplugin's indentexpr=HtmlIndent()
         (when (= ev.match :vue)
           (vim.schedule (fn []
                           (tset vim.bo ev.buf :indentexpr "v:lua.vue_indent()"))))))}))

{: setup}
