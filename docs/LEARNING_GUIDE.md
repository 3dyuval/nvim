# Neovim Navigation & Editing Mastery Guide

## Goal
Master quick navigation and editing in neovim with custom HAEI layout, surround, and tree-sitter text objects for TypeScript, JavaScript, HTML, and JSON.

## Custom Layout (HAEI)
- **h** = left, **a** = down, **e** = up, **i** = right
- **r** = inner (replaces `i`), **t** = around (replaces `a`)

## Text Objects & Operations

### Basic Text Objects
```
rd = inner word    |  td = around word
r( = inner parens  |  t( = around parens  
r{ = inner braces  |  t{ = around braces
r" = inner quotes  |  t" = around quotes
```

### Tree-sitter Text Objects (TypeScript/JavaScript/HTML)
```
rf = inner function   |  Tf = outer function
rc = inner class      |  Tc = outer class  
rp = inner parameter  |  Tp = outer parameter
ro = inner loop       |  To = outer loop
rs = inner scope      |  Ts = outer scope
ry = inner element    |  Ty = outer element (HTML/JSX)
```

## Common Operations

### Copy (c = yank)
```
crf = copy inner function
cTf = copy outer function
crc = copy inner class
cr" = copy inner string
```

### Replace/Change (w = change)
```
wrf = change inner function
wTf = change outer function  
wrc = change inner class
wr" = change inner string
```

### Delete (x = delete)
```
xrf = delete inner function
xTf = delete outer function
xrc = delete inner class
xr" = delete inner string
```

### Select (n = visual)
```
nrf = select inner function
nTf = select outer function
nrc = select inner class
nr" = select inner string
```

## Surround Operations

### Add Surround
```
ys + motion + char
ysrd" = surround inner word with quotes
ysTf{ = surround outer function with braces
```

### Change Surround
```
cs + old + new
cs"' = change quotes to single quotes
cs({ = change parens to braces with space
```

### Delete Surround
```
xs + char
xs" = delete surrounding quotes
xs{ = delete surrounding braces
```

## Language-Specific Patterns

### TypeScript/JavaScript
- Functions: `rf`/`Tf` - arrow functions, methods, declarations
- Classes: `rc`/`Tc` - class definitions and bodies
- Parameters: `rp`/`Tp` - function parameters
- Scope: `rs`/`Ts` - block scope, function scope

### HTML/JSX
- Elements: `ry`/`Ty` - HTML tags, JSX components
- Attributes: Use standard bracket/quote objects

### JSON
- Objects: `r{`/`t{` - JSON objects
- Arrays: `r[`/`t[` - JSON arrays
- Values: `r"`/`t"` - string values

## Navigation
- `]m`/`[m` = next/prev function
- `]c`/`[c` = next/prev class
- `]a`/`[a` = next/prev parameter
- `]o`/`[o` = next/prev loop

## Practice Workflow
1. Navigate to target (tree-sitter navigation)
2. Select appropriate text object (inner vs outer)
3. Apply operation (copy/change/delete/surround)
4. Repeat with muscle memory