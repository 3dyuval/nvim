# Surround Configuration

nvim-surround with Graphite layout translations. Config: `/lua/plugins/surround.lua`

## Keymaps

### Normal Mode
| Key | Action |
|-----|--------|
| `ys{motion}{char}` | Surround motion |
| `yss{char}` | Surround current line |
| `yS{motion}{char}` | Surround motion (with newlines) |
| `ySS{char}` | Surround current line (with newlines) |

### Visual Mode
| Key | Action |
|-----|--------|
| `s{char}` | Surround selection (Graphite) |
| `S{char}` | Surround selection (default) |
| `gS{char}` | Surround selection (with newlines) |

### Delete (Graphite: X=delete)
| Key | Action |
|-----|--------|
| `xs{char}` | Delete surround (Graphite) |
| `xst` | Delete surrounding tag (Graphite) |
| `ds{char}` | Delete surround (default) |

### Change (Graphite: W=change)
| Key | Action |
|-----|--------|
| `ws{old}{new}` | Change surround (Graphite) |
| `cs{old}{new}` | Change surround (default) |
| `cS{old}{new}` | Change surround (with newlines) |

### Insert Mode
| Key | Action |
|-----|--------|
| `<C-g>s` | Insert surround |
| `<C-g>S` | Insert surround (with newlines) |

## Surround Characters

### Brackets (custom spacing: opening=no space, closing=space)
| Char | Result |
|------|--------|
| `(` | `(text)` |
| `)` | `( text )` |
| `[` | `[text]` |
| `]` | `[ text ]` |
| `{` | `{text}` |
| `}` | `{ text }` |
| `>` | `<text>` |
| `<` | `< text >` |

### Quotes (default behavior)
| Char | Result |
|------|--------|
| `"` | `"text"` |
| `'` | `'text'` |

### Markdown (custom)
| Char | Result |
|------|--------|
| `*` | `**text**` (bold) |
| `_` | `_text_` (italic) |
| `~` | `~text~` (strikethrough) |
| `` ` `` | ` ```lang\ntext\n``` ` (code fence, prompts for lang) |

### Prompts
| Char | Prompt | Example |
|------|--------|---------|
| `t` | Tag name | `<div>text</div>` |
| `f` | Function name | `func(text)` |
| `i` | Custom delimiter | `("text")` or `<tag>text</tag>` |

The `i` surround handles:
- Tags: input `<div>` or `div` → `<div>...</div>`
- Delimiter pairs: input `("` → mirrors to `("...")"`

## Aliases
| Alias | Target |
|-------|--------|
| `a` | `>` (angle brackets) |
| `b` | `)` (parentheses) |
| `B` | `}` (braces) |
| `q` | any quote (`"`, `'`, `` ` ``) |
| `s` | any surround |

Note: Default `r` = `]` removed (conflicts with Graphite `r` = inner)

## Known Issues

`ws` (change surround) has layering issues:
1. `w→c` remap intercepts before `ws` recognized
2. Workarounds: disable default `s`, use different prefix, or map specific combos

## Buffer Exclusions

Surround disabled for:
- Non-modifiable buffers
- Special buftypes
- `diffview://` buffers
- `git://` buffers (except `neogit://`)
