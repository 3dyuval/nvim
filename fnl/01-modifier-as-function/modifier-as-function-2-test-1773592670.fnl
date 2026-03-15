;; Test: modifier-as-function (level 2)
;; Created: 2026-03-15

;; -- Question 1 (conceptual) ------------------------------------
;; In Lua, if you write two `[ctrl] = { ... }` blocks inside the
;; same table literal, what happens? Why is this a problem?
;;
;; Answer below as a comment:
;;


;; -- Question 2 (conceptual) ------------------------------------
;; A Fennel macro runs at ___ time, not at ___ time.
;; What does this mean for (C :f) — is there a function call
;; when Neovim loads, or is it already a string?
;;
;; Answer below as a comment:
;;


;; -- Question 3 (implementation) ---------------------------------
;; Write a `modifier` macro that takes a single modifier keyword
;; (:ctrl, :shift, :alt, or :meta) and returns a function.
;; That function takes a key and returns the wrapped string.
;;
;; Example:
;;   (local C (modifier :ctrl))
;;   (C :f)  ;; => "<C-f>"
;;   (C :s)  ;; => "<C-s>"
;;
;; Write your macro here:



;; -- Question 4 (implementation) ---------------------------------
;; Using your macro from Q3, create bindings for C and CS
;; (ctrl+shift), then show what (C :p) and (CS :p) expand to.
;;
;; Hint: CS needs two modifier arguments.
;;
;; Write your code here:



;; -- Question 5 (edge case) -------------------------------------
;; Consider this broken attempt at a modifier macro:
;;
;;   (macro modifier [mod]
;;     (match mod
;;       :ctrl "<C-"))
;;
;; This returns a string, not a function. What goes wrong when
;; you try to use it as (local C (modifier :ctrl)) then (C :f)?
;;
;; Answer below as a comment:
;;
