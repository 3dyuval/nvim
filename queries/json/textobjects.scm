;; extends

; Object/array as a "block" textobject.
; outer = whole {...} / [...] including brackets, inner = contents between them.
(object
  .
  "{"
  _* @block.inner
  "}"
  .) @block.outer

(array
  .
  "["
  _* @block.inner
  "]"
  .) @block.outer