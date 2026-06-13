#!/usr/bin/env python3
"""ZMK keymap formatter for graphite.dtsi-style files.

Reads the whole file from stdin, rewrites the bodies of #define GRAPHITE_*
macros with normalized spacing, and passes everything else through verbatim.

Design:
  - Bindings are split on the & boundary. Each binding is & plus everything
    up to the next &. This handles variable arity without inspecting args.
  - Rows come from the source's own backslash continuation breaks.
    The formatter never re-chunks; it trusts the author's row breaks.
  - Shape and per-row indent are derived from LAYOUT_<N> comments embedded in
    the file. The leading spaces before the first _ on each layout row become
    the indent for that binding row (e.g. thumb row centering). Falls back to
    the hardcoded ROWS dict (zero indent) if no comment is found.
  - Shape validation: on mismatch the formatter exits non-zero so conform
    aborts and leaves the buffer untouched.
  - The emit step is isolated in render_row so alignment policy is swappable.

LAYOUT comment format (embed in the dtsi):
  /* LAYOUT_36:
   * _ _ _ _ _ _ _ _ _ _ _ _
   * _ _ _ _ _ _ _ _ _ _ _ _
   * _ _ _ _ _ _ _ _ _ _ _ _
   *     _ _ _ _ _ _
   */
"""
import re
import sys

# Fallback per-row binding counts (zero indent), keyed by numeric layout suffix.
ROWS = {
    36: [12, 12, 12, 6],
    38: [10, 10, 12, 6],
    42: [13, 15, 14, 6],
}

DEFINE_RE = re.compile(r"^#define\s+(GRAPHITE_\w+)\b")
SUFFIX_RE = re.compile(r"_(\d+)$")
SPLIT_RE = re.compile(r"\s+(?=&)")
LAYOUT_START_RE = re.compile(r"/\*\s*LAYOUT_(\d+)\s*:")
LAYOUT_ROW_RE = re.compile(r"^\s*\*( *)(_[_ ]*)$")
LAYOUT_END_RE = re.compile(r"^\s*\*/")


def parse_layouts(lines: list[str]) -> dict[int, list[tuple[int, int]]]:
    """Extract LAYOUT_<N> as list of (indent, count) per row."""
    layouts: dict[int, list[tuple[int, int]]] = {}
    i = 0
    while i < len(lines):
        m = LAYOUT_START_RE.search(lines[i])
        if m:
            suffix = int(m.group(1))
            rows: list[tuple[int, int]] = []
            i += 1
            while i < len(lines):
                if LAYOUT_END_RE.match(lines[i]):
                    break
                rm = LAYOUT_ROW_RE.match(lines[i])
                if rm:
                    indent = len(rm.group(1))
                    count = rm.group(2).count("_")
                    if count:
                        rows.append((indent, count))
                i += 1
            if rows:
                layouts[suffix] = rows
        i += 1
    return layouts


def split_bindings(text: str) -> list[str]:
    text = text.strip()
    if not text:
        return []
    return [p.strip() for p in SPLIT_RE.split(text) if p.strip()]


def render_row(tokens: list[str], col_width: int, indent: int) -> str:
    return " " * (indent * col_width // 2) + "".join(t.ljust(col_width) for t in tokens).rstrip()


def format_macro(
    name: str,
    rows: list[list[str]],
    layouts: dict[int, list[tuple[int, int]]],
    col_width: int,
) -> list[str]:
    sm = SUFFIX_RE.search(name)
    if not sm:
        raise ValueError(f"{name}: cannot determine layout suffix")
    suffix = int(sm.group(1))

    layout = layouts.get(suffix)
    if layout:
        expected_counts = [c for _, c in layout]
        indents = [i for i, _ in layout]
    else:
        fallback = ROWS.get(suffix)
        if fallback is None:
            raise ValueError(f"{name}: unknown layout suffix {suffix} (known: {sorted(ROWS)})")
        expected_counts = fallback
        indents = [0] * len(fallback)

    counts = [len(r) for r in rows]
    if counts != expected_counts:
        raise ValueError(
            f"{name}: row shape {counts} (total {sum(counts)}) "
            f"does not match expected {expected_counts} (total {sum(expected_counts)}) for _{suffix}"
        )

    return [render_row(r, col_width, indent) for r, indent in zip(rows, indents)]


def collect_macros(lines: list[str]) -> list[tuple[int, str, list[list[str]]]]:
    """First pass: collect (line_index, name, rows) for all GRAPHITE_* macros."""
    result = []
    i = 0
    n = len(lines)
    while i < n:
        m = DEFINE_RE.match(lines[i])
        if m:
            name = m.group(1)
            raw_rows: list[str] = []
            cur = DEFINE_RE.sub("", lines[i], count=1)
            start = i
            while True:
                stripped = cur.rstrip()
                cont = stripped.endswith("\\")
                if cont:
                    stripped = stripped[:-1]
                raw_rows.append(stripped)
                if not cont:
                    break
                i += 1
                if i >= n:
                    break
                cur = lines[i]
            rows = [split_bindings(r) for r in raw_rows]
            rows = [r for r in rows if r]
            result.append((start, name, rows))
        i += 1
    return result


def main() -> int:
    lines = sys.stdin.read().splitlines()
    layouts = parse_layouts(lines)
    macros = collect_macros(lines)

    # One col_width for the entire file — widest token across all macros.
    col_width = max(
        (len(t) for _, _, rows in macros for r in rows for t in r),
        default=6,
    ) + 2

    # Build a set of line indices that are macro body lines (to skip in passthrough).
    macro_lines: dict[int, tuple[str, list[list[str]]]] = {}
    i = 0
    n = len(lines)
    while i < n:
        m = DEFINE_RE.match(lines[i])
        if m:
            name = m.group(1)
            raw_rows: list[str] = []
            cur = DEFINE_RE.sub("", lines[i], count=1)
            start = i
            consumed = [start]
            while True:
                stripped = cur.rstrip()
                cont = stripped.endswith("\\")
                if cont:
                    stripped = stripped[:-1]
                raw_rows.append(stripped)
                if not cont:
                    break
                i += 1
                if i >= n:
                    break
                consumed.append(i)
                cur = lines[i]
            rows = [split_bindings(r) for r in raw_rows]
            rows = [r for r in rows if r]
            macro_lines[start] = (name, rows)
            for ln in consumed[1:]:
                macro_lines[ln] = ("", [])  # body lines, handled via start
        i += 1

    out: list[str] = []
    i = 0
    while i < n:
        if i in macro_lines:
            name, rows = macro_lines[i]
            if not name:  # body line already emitted
                i += 1
                continue
            try:
                formatted = format_macro(name, rows, layouts, col_width)
            except ValueError as exc:
                print(f"format-zmk: {exc}", file=sys.stderr)
                return 1
            out.append(f"#define {name} \\")
            for j, fline in enumerate(formatted):
                sep = " \\" if j < len(formatted) - 1 else ""
                out.append("   " + fline + sep)
        else:
            out.append(lines[i])
        i += 1

    sys.stdout.write("\n".join(out) + "\n")
    return 0


if __name__ == "__main__":
    sys.exit(main())
