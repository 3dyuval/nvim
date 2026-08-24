# Neovim Movement Spec

> The vision and layer model for movement in this config. Assertions describe
> invariants: `[HOLDS]` = verified against live config, `[UNTESTED]` = intended
> but not exercised. Individual bindings live in the code — this spec carries
> only the model needed to reason about interdependencies and conflicts.

## Vision

Movement is **directional first**. Four home-row keys `h a e i` are the sole
direction primitives (left / down / up / right). Every other motion is one of
these *composed with a granularity* — you move in a direction, and a modifier
of case/prefix chooses **how far** (char → word → structure → fold → change).

You should be able to *derive* a motion from the two axes below, not memorize a
flat list. New motions must slot into these axes or they fragment the model.

```
I = Every motion = (direction ∈ {h,a,e,i}) × (granularity layer). Nothing
    directional is bound outside this model.
```

## Layer 1 — Direction primitives (the root)

```
h = left    a = down    e = up    i = right          (mode: n, o, x)
```

```
D1: h/a/e/i map to h/j/k/l in normal, operator, and visual modes   [HOLDS]
    (lua/config/keymaps.lua — the base `map({[mode]={n,o,x}, ...})`)
D2: These are the ONLY bare directional keys. j/k/l/h are not used
    directly in any keymap RHS-as-intent; they are the target, not the key [HOLDS]
D3: Vertical (a/e) and horizontal (h/i) are symmetric — no axis-specific
    divergence at the base layer (unlike hypr, which diverges on SUPER)   [HOLDS]
```

Consequence: because the base occupies `n/o/x`, an operator + direction already
composes (`<op>a` = op downward). Granularity layers extend the *reach* of a
direction; they do not re-map the direction itself.

## Layer 2 — Motion granularity (how far)

Granularity ascends from a single character to a semantic region. Each rung
keeps the directional intent; the **key form** signals the rung.

```
rung          keys                       meaning                         mode
────────────  ─────────────────────────  ──────────────────────────────  ──────
char          h a e i                    ← ↓ ↑ →                          n o x
word          l / L / D                  word-back / WORD-back / WORD-fwd n o x
end-of-word   <M-h> / <M-o>              end WORD back / fwd              n o x
structural    H A E I                    treewalk ← ↓ ↑ → (out/sib/sib/in) n
fold          zh zi / zH zI              fold close/open one / all        n
change/hunk   ga / ge                    next / prev hunk (or ]c/[c)      n
bracket       %                          matching bracket                n o x
```

```
G1: word motions live on l/L/D (back/WORD-back/WORD-fwd); forward word is
    plain `w` (unshadowed) — d was freed from word-fwd to serve delete     [HOLDS]
G2: structural nav (Treewalker) is capital HAEI — H/A/E/I walk the SAME
    four directions as lowercase h/a/e/i: H=out(parent) I=in(child)
    E=prev-sibling A=next-sibling. Capital = "move by structure".         [HOLDS]
    (fnl/config/keymaps/movement.fnl) Frees native A (insert-end, on W/S)
    and E (end-WORD, on <M-h>/<M-o>).
G2a: structural nav CLIMBS rather than dead-ends. E = prev-sibling, or if
     there is none, move_out to the parent — so repeated E ascends the tree.
     Detected by move_up leaving the row unchanged (Treewalker moves by row,
     anchor.current uses line('.')), guarded on a parser so a non-TS buffer
     no-ops once. Composes only the public move_up/move_out — no plugin
     internals. A is plain next-sibling (no climb) by choice; the axis is
     intentionally asymmetric.                                            [HOLDS]
G3: fold layer is z-prefix + horizontal HAEI (depth axis, mirroring
    structural H/I): zh=close-one zi=open-one; capital = all (zH/zI, ufo).
    z is the native fold prefix — freed by reverting undo to native u.     [HOLDS]
G4: change navigation is ga/ge and is context-aware: gitsigns nav_hunk in
    a normal buffer, native ]c/[c when vim.wo.diff is set                  [HOLDS]
G5: key-form conventions — a new motion SHOULD reuse the matching form:
      capital H/A/E/I  = structural (treewalk) in that direction
      capital L/D      = WORD (larger word)
      z-prefix + h/i   = fold (zh/zi one, zH/zI all)
      g-prefix         = change-nav (ga/ge)                               [UNTESTED]
```

## Layer 3 — Bracket navigation (typed forward/back)

Where HAEI is *directional* (move by geometry) and structural HAEI walks the
tree, the `[`/`]` layer is *typed* sequential navigation: **`]` = forward,
`[` = backward**, and the trailing token picks WHAT you step over. This is the
nvim-treesitter-textobjects `move` axis plus one buffer override.

```
]<t> / [<t>   next / prev textobject of type <t>       (n x o)
]] / [[       next / prev BUFFER                        (n)

  t   target (from fnl/treesitter/textobjects.fnl)
  ─   ────────────────────────────────────────────
  f   function.outer      (]M/[M = function END)
  C   class.outer
  p   parameter.inner
  l   loop
  s   scope
  u   fold
```

```
I = ] = forward, [ = backward. Single bracket + letter = next/prev textobject;
    doubled bracket = next/prev buffer.

K1: single-bracket typed nav is treesitter-textobjects move, bound manually
    per capture (main branch — see textobjects.fnl setup()):
      ]f [f functions, ]M [M function-end, ]C [C class, ]p [p param,
      ]l [l loop, ]s [s scope, ]u [u fold                                 [HOLDS]
K2: doubled bracket = buffer nav — ]]=bnext [[=bprev. This REPLACES native
    section motion (]]/[[), an accepted loss.                              [HOLDS]
    (fnl/config/keymaps/movement.fnl)
K3: capital swap-letter = swap, not move: ]F/[F swap function, ]P/[A swap
    param. Swap rides the same ]/[ = forward/back sense.                   [HOLDS]
K4: %% still jumps to the matching bracket (native, n o x). Distinct from
    the ]/[ layer — % is pair-match, not sequential.                      [HOLDS]
```

Note: `]]`/`[[` are re-bound BUFFER-LOCAL inside the snacks explorer
(conflict/error nav, snacks.lua) — see X6. Everywhere else they are buffer nav.

## Conflict & precedence rules

The system stays coherent only because a few overlaps resolve deterministically
by **load order** and **buffer-locality**. These are the load-bearing invariants.

```
Load order (lua/config/keymaps.lua):
  1. base HAEI + `ga/ge = scroll`         (keymaps.lua top)
  2. require("config.keymaps.modes")       (line ~728)
       → require("config.keymaps.movement") → `ga/ge = hunk nav`
  3. require("config.keymaps-old")         (word motions l/L/D, etc.)
```

```
X1: ga/ge are defined TWICE — scroll (keymaps.lua) then hunk-nav
    (movement.fnl, loaded later). Hunk-nav WINS globally.                  [HOLDS]
    → "scroll (Graphite)" descs are vestigial; PageUp/PageDown carry scroll.
X2: Inside diffview, ga/ge are re-bound BUFFER-LOCAL (conflict/hunk aware)
    and override the global hunk-nav there.                                [HOLDS]
    (fnl/plugins/diffview-plus.fnl)
X3: `x`/`X` are RETIRED → notify "use d"; `d` is the delete operator.
    Any "x = delete" claim elsewhere (skills/docs) is stale.              [HOLDS]
X4: PageUp/PageDown = scroll globally; <S-PageUp>/<S-PageDown> = prev/next
    file inside diffview panels; <C-S-PageUp/Down> = buffer prev/next.
    The three Page tiers must stay distinct.                               [HOLDS]
X5: A new global directional/motion binding MUST check it is not shadowed
    by a later-loaded module (movement, keymaps-old) or a plugin's
    buffer-local map before being considered active.                       [UNTESTED]
X6: ]]/[[ are BUFFER-LOCAL re-bound in the snacks explorer to conflict/error
    nav (snacks.lua) — overriding the global buffer-nav (K2) there only.   [HOLDS]
X7: undo reverted to native — u=undo, <C-r>=redo, U=undo-line. This frees z
    as the native fold prefix (G3). Old z=undo / gz=undo-line are removed. [HOLDS]
```

## Files

| File | Role |
|---|---|
| `lua/config/keymaps.lua` | Base HAEI (`h/a/e/i`), operator retirement (`x`→notify), scroll `ga/ge` (later overridden), Page tiers; loads the fnl modules at the bottom |
| `fnl/config/keymaps/movement.fnl` | Granularity layers: Treewalker (structural), folds, hunk nav `ga/ge` (overrides scroll), till `k/K` |
| `lua/config/keymaps-old.lua` | Legacy word/WORD motions (`l/L/D`, `<M-h>/<M-o>`), open-line, replace, jumplist — loaded last |
| `fnl/plugins/diffview-plus.fnl` | Buffer-local `ga/ge` (conflict/hunk aware) + `<S-Page>` file nav inside diffview |
| `fnl/config/keymaps/modes.fnl` | Require-order hub: pulls in movement/insert/search/etc. |

## Extending

To add a motion without fragmenting the model:

1. Pick the **direction** from `h/a/e/i` (or a granularity key that already
   encodes direction, e.g. `ga`/`ge`).
2. Pick the **rung** and reuse its key-form convention (G5).
3. Verify **precedence** (X5): grep the later-loaded modules and any plugin
   buffer-local maps for the key; confirm your binding is the one that wins
   where you intend, and is correctly shadowed where a mode owns it (diffview).
