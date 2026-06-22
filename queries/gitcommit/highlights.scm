; Gitcommit custom highlights for markdown-like syntax with conventional commits

; Conventional commits - subject prefix (type)
((line) @keyword
 (#match? @keyword "^[a-z]+(!)?:"))

; Markdown-style headers (# = h1, ## = h2, etc.)
((line) @markup.heading.1
 (#match? @markup.heading.1 "^#+ "))

; Semicolon comments (instead of # for git comment char)
((_) @comment
 (#match? @comment "^;.*"))

; Highlight @@ diff hunk markers - these will be folded
((line) @diff.hunk
 (#match? @diff.hunk "^@@"))

; Diff headers (diff --git, index, ---, +++)
((line) @diff.header
 (#match? @diff.header "^(diff|index|---|\\+\\+\\+|old mode|new mode)"))

; Added/removed lines in diff
((line) @diff.plus
 (#match? @diff.plus "^\\+"))

((line) @diff.minus
 (#match? @diff.minus "^-"))

; Diff context lines
((line) @diff.context
 (#match? @diff.context "^ "))

; Scissors/cut line
((line) @comment
 (#match? @comment "^---+ >8 ---"))

; Message body and trailers are spell-checked
((line) @spell
 (#match? @spell "^[^#;@\\-+]"))
