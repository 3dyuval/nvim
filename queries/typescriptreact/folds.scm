; Fold imports (treesitter will group consecutive ones)
(import_statement) @fold

; Fold export blocks
(export_statement) @fold

; Fold functions
(function_declaration) @fold
(arrow_function) @fold
(method_definition) @fold

; Fold classes
(class_declaration) @fold

; Fold interfaces
(interface_declaration) @fold

; Fold type aliases
(type_alias_declaration) @fold

; Fold objects
(object) @fold

; Fold arrays
(array) @fold

; Angular decorator property arrays - CURRENTLY DISABLED
; These queries work but UFO only supports 2 providers (main + fallback)
; We use LSP + indent for TypeScript to get auto-folding imports
; When UFO issue #256 is resolved, we can use { "lsp", "treesitter", "indent" }
; https://github.com/kevinhwang91/nvim-ufo/issues/256

; (pair
;   key: (property_identifier) @key (#eq? @key "imports")
;   value: (array) @fold)
; 
; (pair
;   key: (property_identifier) @key (#eq? @key "declarations")
;   value: (array) @fold)
; 
; (pair
;   key: (property_identifier) @key (#eq? @key "providers")
;   value: (array) @fold)
; 
; (pair
;   key: (property_identifier) @key (#eq? @key "exports")
;   value: (array) @fold)
; 
; (pair
;   key: (property_identifier) @key (#eq? @key "deps")
;   value: (array) @fold)
; 
; (pair
;   key: (property_identifier) @key (#eq? @key "routes")
;   value: (array) @fold)

; Fold JSX elements
(jsx_element) @fold
(jsx_fragment) @fold

; Fold switch statements
(switch_statement) @fold

; Fold try-catch blocks
(try_statement) @fold

; Fold if statements (optional)
; (if_statement) @fold