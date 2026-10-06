;; Pick a package.json script, run it, route output to the quickfix list with
;; file:line navigation. Package manager is detected from the lockfile next to
;; the package.json (bun > pnpm > yarn > npm).
(local M {})

(fn find-package-json [start]
  "Walk up from `start` dir, return the nearest package.json path or nil."
  (let [found (vim.fs.find "package.json"
                           {:upward true :type "file" :path start})]
    (. found 1)))

(fn detect-pm [dir]
  "Return the run prefix for the lockfile present in `dir`."
  (if (= 1 (vim.fn.filereadable (.. dir "/bun.lockb"))) ["bun" "run"]
      (= 1 (vim.fn.filereadable (.. dir "/bun.lock"))) ["bun" "run"]
      (= 1 (vim.fn.filereadable (.. dir "/pnpm-lock.yaml"))) ["pnpm" "run"]
      (= 1 (vim.fn.filereadable (.. dir "/yarn.lock"))) ["yarn" "run"]
      ["npm" "run"]))

(fn read-scripts [pkg-path]
  "Parse the scripts table from package.json; returns (scripts-table dir) or nil."
  (let [(ok data) (pcall vim.fn.readfile pkg-path)]
    (when ok
      (let [(ok2 parsed) (pcall vim.json.decode (table.concat data "\n"))]
        (when (and ok2 parsed parsed.scripts)
          (values parsed.scripts (vim.fs.dirname pkg-path)))))))

;; errorformat with %t (type) so the quickfix window colors the E/W sigil
;; (syntax/qf.vim -> qfError/qfWarning) and truncates messages natively.
(local efm
  (table.concat
    ["%f(%l\\,%c): %t%*[a-z] %m"   ; tsc:    src/a.ts(12,5): error TS2322: ...
     "%f:%l:%c: %t%*[a-z] %m"      ; eslint: src/a.ts:12:5: error ...
     "%f:%l:%c %m"                 ; file:line:col msg
     "%f:%l:%c"                    ; bare file:line:col
     "%-G%.%#"]                    ; ignore everything else
    ","))

(fn anchor-dir [dir script-cmd]
  "Scripts often `cd <sub> && ...`, so tool output paths are relative to <sub>,
  not the package.json dir. If the command leads with `cd X`, anchor there."
  (let [sub (and script-cmd (script-cmd:match "^%s*cd%s+([^%s&|;]+)"))]
    (if sub (vim.fs.normalize (.. dir "/" sub)) dir)))

(fn run-script [pm dir script script-cmd]
  "Run `<pm> run <script>` in dir, collect output into quickfix, open it."
  (let [cmd [(. pm 1) (. pm 2) script]
        anchor (anchor-dir dir script-cmd)
        title (.. (table.concat cmd " "))]
    (vim.notify (.. "Running: " title) vim.log.levels.INFO)
    (vim.system cmd {:cwd dir :text true}
      (vim.schedule_wrap
        (fn [out]
          (let [lines (vim.split (.. (or out.stdout "") "\n" (or out.stderr "")) "\n")
                save-efm vim.o.errorformat]
            (set vim.o.errorformat efm)
            ;; Parse with cwd = the dir the tool's paths are relative to.
            (vim.cmd (.. "lcd " (vim.fn.fnameescape anchor)))
            (vim.fn.setqflist [] " " {:title title :lines lines})
            (set vim.o.errorformat save-efm)
            (let [n (. (vim.fn.getqflist {:size 1}) :size)]
              (if (> n 0)
                  (do (vim.cmd "copen") (vim.notify (.. title ": " n " qf entries")))
                  (vim.notify (.. title ": done (exit " out.code ", no matches)")
                              (if (= out.code 0) vim.log.levels.INFO
                                  vim.log.levels.WARN))))))))))

(fn M.pick []
  "Pick a script from the nearest package.json and run it to the quickfix list."
  (let [buf-dir (vim.fs.dirname (vim.api.nvim_buf_get_name 0))
        start (if (and buf-dir (not= buf-dir "")) buf-dir (vim.fn.getcwd))
        pkg (find-package-json start)]
    (if (not pkg)
        (vim.notify "No package.json found" vim.log.levels.WARN)
        (let [(scripts dir) (read-scripts pkg)]
          (if (not scripts)
              (vim.notify "package.json has no scripts" vim.log.levels.WARN)
              (let [pm (detect-pm dir)
                    items []]
                (each [name cmd (pairs scripts)]
                  (table.insert items {:text name :cmd cmd}))
                (table.sort items (fn [a b] (< a.text b.text)))
                (Snacks.picker.pick
                  {:source "pkg_scripts"
                   :items items
                   :format (fn [item _]
                             [[item.text :SnacksPickerLabel]
                              [(.. "  " (or item.cmd "")) :SnacksPickerComment]])
                   :confirm (fn [picker item]
                              (picker:close)
                              (when (and item item.text)
                                (run-script pm dir item.text item.cmd)))})))))))

M
