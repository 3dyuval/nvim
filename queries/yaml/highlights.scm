; extends

; Highlight GitHub Actions expressions ${{ ... }}
((string_scalar) @string.special
  (#lua-match? @string.special "%${{.*}}"))
