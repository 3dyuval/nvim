; Amber highlights for nvim-treesitter
; See: https://github.com/nvim-treesitter/nvim-treesitter/pull/6909
; NOTE: The grammar reuses a single (variable) node for all identifiers
; (functions, parameters, variables). Distinct highlights rely on parent
; context queries. A more mature grammar would have separate node types.

; Keywords
[
  "let"
  "const"
  "main"
  "pub"
  "as"
  "is"
  "in"
] @keyword

(reference) @keyword

"import" @keyword.import
"from" @keyword.import

"fun" @keyword.function

[
  "return"
  "fail"
] @keyword.return

[
  "if"
  "else"
  "then"
] @keyword.conditional

[
  "for"
  "loop"
  "while"
] @keyword.repeat

[
  "break"
  "continue"
] @keyword.repeat

[
  "and"
  "not"
  "or"
] @keyword.operator

; Error handling
[
  "failed"
  "succeeded"
  "exited"
  "trust"
  "unsafe"
  "silent"
] @keyword.exception

(handler_propagation) @keyword.exception

; Builtins
[
  "echo"
  "exit"
  "cd"
  "mv"
  "sudo"
  "nameof"
  "len"
  "lines"
] @function.builtin

(status) @variable.builtin

; Functions
(function_definition
  name: (variable) @function)

(function_call
  name: (variable) @function.call)

; Parameters
(function_parameter_list_item
  (variable) @variable.parameter)

; Variables
(variable_init
  (variable_assignment
    (variable) @variable))

(variable_assignment
  (variable) @variable)

(variable) @variable

; Types
(type_name_symbol) @type.builtin

; Literals
(boolean) @boolean

(null) @constant.builtin

(number) @number

(string) @string

(string_content) @string

(escape_sequence) @string.escape

(interpolation
  "{" @punctuation.special
  "}" @punctuation.special)

; Commands (shell)
(command) @string.special

(command_content) @string.special

(command_option) @variable.parameter

; Operators
[
  "="
  "+="
  "-="
  "*="
  "/="
  "%="
  "+"
  "-"
  "*"
  "/"
  "%"
  ">"
  "<"
  ">="
  "<="
  "=="
  "!="
] @operator

; Punctuation
[
  "("
  ")"
  "{"
  "}"
  "["
  "]"
] @punctuation.bracket

[
  ","
  ";"
  ":"
] @punctuation.delimiter

"$" @punctuation.special

; Comments
(comment) @comment @spell

; Preprocessor
(preprocessor_directive) @keyword.directive

(shebang) @keyword.directive
