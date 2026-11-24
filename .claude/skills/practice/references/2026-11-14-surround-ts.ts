// drill: surround on real TypeScript (ds / cs / ys + nested brackets)
// subject: deleting/changing/adding surrounds, and picking outer vs inner on
//   nested pairs; treesitter finds (rf/tf = inner/around function)
// augment: real .ts buffer so surround resolves via treesitter — the fenced
//   examples in surround-textobjects.md do NOT work (markdown ft). inner=r,
//   around=t. ds<char> deletes the NEAREST enclosing pair; move onto the OUTER
//   paren to target the outer one.
//
// - [ ] TODO: §1 cursor inside, ds( → (should delete the surrounding parens)
// - [ ] TODO: §2 cursor on the OUTER ( (col 1), ds( → (should remove only the outer pair)
// - [ ] TODO: §3 cursor inside inner, ds( → (should remove the inner pair only)
// - [ ] TODO: §4 cursor inside, cs([ → (should change parens to brackets)
// - [ ] TODO: §5 cursor inside, cs`" → (should change backticks to quotes)
// - [ ] TODO: §6 cursor on word, ysrw( → (should wrap the word in parens)
// - [ ] TODO: §7 cursor on return, ysrf( → (should wrap the function body only)
// - [ ] TODO: §8 cursor on return, ystf( → (should wrap the whole function)

// §1
const s1 = (hello)

// §2
const s2 = ((keepInner))

// §3
const s3 = ((cursorHere))

// §4
const s4 = (swapMe)

// §5
const s5 = `inlineCode`

// §6
const s6 = wrapThisWord

// §7
function s7() {
  return "body only"
}

// §8
function s8() {
  return "whole function"
}
