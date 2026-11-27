;; (register prefix node): node value is a cmd string/fn, {:cmd :desc}, or a
;; nested table (recursed). :group is a which-key label, skipped when binding.
(fn register [prefix node]
  (each [key val (pairs node)]
    (when (not= key :group)
      (let [lhs (.. prefix key)]
        (if (and (= (type val) :table) val.cmd)
            (vim.keymap.set :n lhs val.cmd {:desc (or val.desc "")})
            (= (type val) :table)
            (register lhs val)
            (vim.keymap.set :n lhs val {:desc ""}))))))

;; Run f after VeryLazy — lets maps/dels win over LazyVim's defaults.
(fn very-lazy [f]
  (let [(ok lv) (pcall require :lazyvim.util)]
    (if (and ok lv lv.on_very_lazy)
        (lv.on_very_lazy f)
        (vim.api.nvim_create_autocmd :User
          {:pattern :VeryLazy :callback (fn [] (f) nil)}))))

(fn register-very-lazy [prefix node]
  (very-lazy #(register prefix node)))

(fn del-very-lazy [mode keys]
  (very-lazy #(each [_ lhs (ipairs keys)]
                (pcall vim.keymap.del mode lhs))))

{: register : very-lazy : register-very-lazy : del-very-lazy}
