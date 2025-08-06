;; extends

; Custom jsx self-closing element textobject
(jsx_self_closing_element) @jsx_self_closing_element

; Make element queries work with self-closing
(jsx_self_closing_element) @element.outer
(jsx_self_closing_element) @tag.outer
