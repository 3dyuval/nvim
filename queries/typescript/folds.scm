; Fold imports
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

; Fold switch statements
(switch_statement) @fold

; Fold try-catch blocks
(try_statement) @fold

; Fold if statements (optional)
; (if_statement) @fold