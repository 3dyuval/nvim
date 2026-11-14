// drill: register-safe paste + black-hole delete
// subject: keeping a yank alive across deletes; the "" vs "0 vs "_ registers
// augment: operators are vanilla (y/d/c/p/v) but inner-word is rw (HAEI, NOT
//   iw). "" = unnamed (clobbered by d/c/x/visual-p). "0 = last yank only
//   (survives deletes). "_ = black hole (writes nowhere).
//
// - [ ] TODO: §1 yrw apple, drw banana, vrwp cherry → (should clobber: cherry becomes banana — the bug)
// - [ ] TODO: §2 yrw apple, drw banana, vrw cherry then "0p → (should keep the yank: cherry becomes apple)
// - [ ] TODO: §3 yrw keep, vrw cherry, "_dP → (should paste over without clobbering the yank)
// - [ ] TODO: §4 yrw keep, "_dd trash line, p elsewhere → (should delete the line without touching the yank)
// - [ ] TODO: §5 yrw keep, "_crw target then type → (should change without stealing the register)

// §1
const a1 = apple
const a2 = banana
const a3 = cherry


// §2
const b1 = apple
const b2 = banana
const b3 = cherry


// §3
const c1 = keep
const c2 = cherry


// §4
const keepMe = keep
const trashLine = DELETE_ME_WITHOUT_STEALING_REGISTER


// §5
const d1 = keep
const d2 = targetToChange
