; Tree-sitter folding query for gitcommit buffers
; Fold content between @@ diff hunk markers

; Match any line that starts with @@ and use it to define fold regions
((_) @fold
 (#match? @fold "^@@"))
