;; coerce.nvim — case conversion (camelCase, snake_case, kebab-case, etc.)
;; Simpler alternative to text-case.nvim, no LSP dependencies
{1 "gregorias/coerce.nvim"
 :tag "v5.0.0"
 :event :VeryLazy
 :config
 (fn []
   (let [coerce (require :coerce)
         case-m (require :coerce.case)
         register-case (fn [key case-fn desc]
                         (coerce.register_case {:keymap key
                                                :case case-fn
                                                :description desc}))]
     ;; Register custom cases for gu + key
     (register-case "L" vim.fn.tolower "lowercase")
     (register-case "U" vim.fn.toupper "UPPERCASE")
     (register-case "S" case-m.to_snake_case "snake_case")
     (register-case "K" case-m.to_kebab_case "kebab-case")
     (register-case "C" case-m.to_camel_case "camelCase")
     (register-case "P" case-m.to_pascal_case "PascalCase")
     (register-case "A" case-m.to_upper_case "CONSTANT_CASE")
     (register-case "D" case-m.to_dot_case "dot.case")
     (register-case "T" case-m.to_title_case "Title Case")
     
     (coerce.setup)
     ;; Normal mode: gu + case key (e.g., guL, guS, guK)
     (vim.keymap.set :n "gu" "<Plug>(coerce-normal)" {:desc "Coerce word"})
     ;; Visual mode: select + gu + case key
     (vim.keymap.set :v "gu" "<Plug>(coerce-visual)" {:desc "Coerce selection"})))}
