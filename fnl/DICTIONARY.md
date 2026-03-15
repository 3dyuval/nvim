# Fennel Keymap DSL — Dictionary

## Part 1: Modifier as a Function

The core insight: a modifier is a function that wraps a key with a prefix string. Declare it once, apply it to each binding.

### 1.1 The `modifier` macro

Returns a function that prepends the modifier prefix to a key at compile time.

```fennel
(macro modifier [& mods]
  `(fn [key#]
     (.. ,(icollect [_ m (ipairs mods)]
            (match m
              :ctrl  "<C-"
              :shift "<S-"
              :alt   "<A-"
              :meta  "<M-"))
         key# ">")))
```

Usage:

```fennel
(local C (modifier :ctrl))
;; (C :f) expands to "<C-f>" at compile time
```

### 1.2 Composition

Multiple modifiers compose explicitly:

```fennel
(local CS (modifier :ctrl :shift))
;; (CS :p) expands to "<C-S-p>"
```

### 1.3 Key property

No runtime cost. The modifier resolves during Fennel compilation — by the time Lua runs, it's a plain string literal. No table lookup, no function call at runtime.

### 1.4 Contrast with Lua DSL

The Lua `[ctrl]` table key was clever but created silent-overwrite when two `[ctrl]` blocks appeared in the same table. Fennel's `(C :f)` is the key string — visible, composable, conflict-detectable at compile time.

---

## Part 2: Flat Bindings with `defkeys`

A flat list of `(modifier key) description action` triples. No nesting, no grouping structure — comments provide visual sections.

### 2.1 The `defkeys` macro

```fennel
(macro defkeys [mode & bindings]
  ;; Walks bindings in triples: key, desc, action
  ;; Emits vim.keymap.set calls
  ...)
```

### 2.2 Usage

```fennel
(local C (modifier :ctrl))

(defkeys :n
  ;; files
  (C :f) "Find files (git root)"     files.find_files
  (C :s) "Save file"                 files.save_file
  (C :S) "Save and stage file"       files.save_and_stage_file

  ;; search
  (C "/") "SearXNG Autocomplete"     (cmd "SearxngAutocomplete")
  (C "\\") "SearXNG Engines"         (cmd "SearxngEngines")

  ;; buffers
  (C :p) "Previous buffer"           (cmd "bprev")
  (C ".") "Next buffer"              (cmd "bnext")
  (C "-") "Toggle buffer menu"       (cmd "BentoToggle")
  (C :k) "Previous buffer (alt)"     (cmd "bprev")
  (C :y) "Next buffer (alt)"         (cmd "bnext"))
```

### 2.3 Visual grouping

Comments are sections for the author. The compiler sees a flat list. Merging two "ctrl" groups is a non-issue because there are no blocks — just individual bindings.

```fennel
(defkeys :n
  ;; -- files ------------------------------------
  (C :f) "Find files (git root)"     files.find_files

  ;; -- buffers ----------------------------------
  (C :p) "Previous buffer"           (cmd "bprev"))
```

### 2.4 The `cmd` helper

```fennel
(macro cmd [name]
  `(.. "<Cmd>" ,name "<CR>"))
```

Wraps a Neovim command string. `(cmd "bprev")` expands to `"<Cmd>bprev<CR>"`.

---

## Part 3: Nested Grouping with `defgroup`

Tree structure where modifiers and semantic labels nest. The macro walks the tree at compile time and emits flat `vim.keymap.set` calls.

### 3.1 The `defgroup` macro

```fennel
(macro defgroup [mode & body]
  (fn walk [nodes key-prefix group-prefix]
    ...)
  `(do ,(walk body "" "")))
```

### 3.2 Two accumulator tracks

The walk function maintains two independent accumulators:

- **key-acc** — modifier characters that become part of the actual key string
- **group-acc** — semantic names that become which-key group labels

```fennel
(fn walk [nodes key-acc group-acc results]
  (match v
    ;; modifier - extends key-acc only
    :ctrl  (walk ... (.. key-acc "C-") group-acc ...)
    :shift (walk ... (.. key-acc "S-") group-acc ...)

    ;; semantic group - extends group-acc only
    name   (walk ... key-acc (.. group-acc name "/") ...)

    ;; leaf - reads both accumulators
    key    (emit {: full-key : desc : action :group group-acc})))
```

### 3.3 Modifier nesting

Nesting accumulates — inner modifiers append to the prefix, they don't replace it.

```fennel
(defgroup :n
  (ctrl
    :f "Find files"     files.find_files    ; -> <C-f>

    (alt
      :f "Find (alt)"   files.find_alt)))   ; -> <C-A-f>
```

Walk trace:
```
ctrl       -> key-acc = "C-"
  :f       -> "<C-f>"
  alt      -> key-acc = "C-A-"
    :f     -> "<C-A-f>"
```

### 3.4 Same key, different modifier depths

```fennel
(defgroup :n
  (ctrl
    :p "Prev buffer"          (cmd "bprev")      ; -> <C-p>

    (shift
      :p "Prev buffer fast"   (cmd "bprev5"))    ; -> <C-S-p>

    (alt
      :p "Prev tab"           (cmd "tabprev")))) ; -> <C-A-p>
```

Three actions on `:p` — differentiated by modifier depth. No duplication, no silent overwrites.

### 3.5 Semantic groups alongside modifiers

```fennel
(defgroup :n
  (ctrl
    (files
      :f "Find files"          files.find_files    ; -> <C-f>, group: files/
      :s "Save"                files.save_file)    ; -> <C-s>, group: files/

    (shift
      (files
        :f "Find (global)"     files.find_global   ; -> <C-S-f>, group: files/
        :s "Save all"          files.save_all))))  ; -> <C-S-s>, group: files/
```

`files` contributes to the group name but not the key string. `shift` contributes to the key string but not the group name. They compose independently.

### 3.6 Compile-time duplicate detection

```fennel
;; Compile error — duplicate :f at the same level
(defgroup :n
  (ctrl :f "Find files" files.find_files)
  (ctrl :f "Find files" files.find_files))

;; Fine — ctrl appears once, wraps everything
(defgroup :n
  (ctrl
    :f "Find files"  files.find_files
    :s "Save file"   files.save_file))
```

The original Lua bug (two `[ctrl]` keys in one table silently overwriting) disappears structurally.

---

## Part 4: Migration Strategy

### 4.1 The seam

`lua/config/keymaps.lua` is the seam file. It requires both old Lua blocks and new compiled Fennel modules simultaneously. During migration, both coexist.

### 4.2 Migration per group

Each group follows the same cycle:

1. Write `.fnl` file in `fnl/config/keymaps/`
2. Add `require` to `keymaps.lua` (hotpot resolves it from `fnl/`)
3. Comment out old block
4. Run tests (`make test`)
5. Delete old block after one week of stable use

### 4.3 Order by complexity

```
clipboard.fnl     -- self-contained, all named functions, low risk
navigation.fnl    -- bracket pairs, needs nav-hunk helper
ctrl.fnl          -- merged ctrl group, tests modifier nesting
files.fnl         -- file operations, may have inline logic
surround.fnl      -- replaces keymaps-surround.lua, most complex
```

### 4.4 What stays

`keymap-utils/` is a library, not config. It stays tested and intact. The Fennel layer compiles down to it (or directly to `vim.keymap.set`).

### 4.5 hotpot.nvim

`hotpot.nvim` replaces the Makefile compile/watch cycle:

- Intercepts `require()` and compiles `.fnl` files on demand
- Caches compiled Lua internally — no `.lua` artifacts in your tree
- Files ending in `macros.fnl` or `macro.fnl` get the macro compiler environment automatically
- Inspect compiled output with `:Hotpot eval` or `:Hotpot log`

```lua
-- early in init.lua, before any fennel requires
require("hotpot")
```

---

## Part 5: Fennel Fundamentals for This Project

### 5.1 `local` bindings

```fennel
(local C (modifier :ctrl))
(local files (require :utils.files))
```

### 5.2 `require-macros`

Imports macros from another file — available at compile time only.

```fennel
(require-macros :config.macros.keymap)
```

### 5.3 `match` expressions

Pattern matching used inside macros to dispatch on modifier names:

```fennel
(match m
  :ctrl  "<C-"
  :shift "<S-"
  :alt   "<A-"
  :meta  "<M-")
```

### 5.4 `icollect`

Iterator that collects results into a sequential table:

```fennel
(icollect [_ m (ipairs mods)]
  (match m ...))
```

### 5.5 String concatenation

```fennel
(.. "<C-" key ">")   ; -> "<C-f>"
```

### 5.6 Quasiquote and unquote

Macros use backtick (quasiquote) and comma (unquote) to construct code:

```fennel
`(fn [key#]
   (.. ,prefix key# ">"))
```

`key#` is a gensym — compiler generates a unique name to avoid capture.

### 5.7 Varargs in macros

```fennel
(macro modifier [& mods]
  ;; mods is a sequential table of all arguments
  ...)
```
