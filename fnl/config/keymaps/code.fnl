;; <leader>c* code actions (migrated out of the retired lua/config/keymaps.lua).
(local {: register} (require :config.keymaps.register))
(local code (require :utils.code))
(local editor (require :utils.editor))

(register "<leader>c"
  {:group "Code"
   :o {:cmd code.organize_imports          :desc "Organize + Remove Unused Imports"}
   :O {:cmd code.organize_imports_and_fix  :desc "Organize Imports + Fix All Diagnostics"}
   :I {:cmd code.add_missing_imports       :desc "Add missing imports"}
   :u {:cmd code.remove_unused_imports     :desc "Remove unused imports"}
   :F {:cmd code.fix_all                   :desc "Fix all diagnostics"}
   :V {:cmd code.select_ts_version         :desc "Select TS workspace version"}
   :t {:cmd editor.typescript_check        :desc "TypeScript check (tsc)"}
   :g {:cmd editor.typescript_check_go     :desc "TypeScript check (tsgo)"}
   :C {:cmd ":Claude<CR>"                  :desc "Claude replace"}})
