#!/usr/bin/env python3
"""ZMK keymap binding query and setter for graphite.dtsi-style files.

Usage:
  zmk-binding.py get --layout 36 --row 2 --col 1 [file]
  zmk-binding.py set --layout 36 --row 2 --col 1 "&kp TAB" [file]

Coordinates are 1-based (row 1 = top row, col 1 = leftmost key).
File defaults to stdin/stdout when omitted.

Internal model:
  Coord = (layout: int, row: int, col: int)  -- all 1-based
  The coord_to_index() function maps a Coord to a flat token index
  within the macro body. This is the single place to extend with
  named positions, 0-based coords, board-specific aliases, etc.
"""
import re
import sys
from dataclasses import dataclass

# ---------------------------------------------------------------------------
# Coordinate model
# ---------------------------------------------------------------------------

@dataclass(frozen=True)
class Coord:
    layout: int
    row: int
    col: int


def coord_to_index(coord: Coord, row_counts: list[int]) -> int:
    """Map a 1-based (row, col) to a flat token index within the macro.

    Raises ValueError if the coord is out of range.
    This is the single extension point for future coordinate schemes.
    """
    if coord.row < 1 or coord.row > len(row_counts):
        raise ValueError(f"row {coord.row} out of range (1..{len(row_counts)})")
    row_idx = coord.row - 1
    max_col = row_counts[row_idx]
    if coord.col < 1 or coord.col > max_col:
        raise ValueError(f"col {coord.col} out of range (1..{max_col}) for row {coord.row}")
    return sum(row_counts[:row_idx]) + (coord.col - 1)


# ---------------------------------------------------------------------------
# Parser (shared with format-zmk.py logic)
# ---------------------------------------------------------------------------

DEFINE_RE = re.compile(r"^#define\s+(GRAPHITE_\w+)\b")
SUFFIX_RE = re.compile(r"_(\d+)$")
SPLIT_RE = re.compile(r"\s+(?=&)")
LAYOUT_START_RE = re.compile(r"/\*\s*LAYOUT_(\d+)\s*:")
LAYOUT_ROW_RE = re.compile(r"^\s*\*( *)(_[_ ]*)$")
LAYOUT_END_RE = re.compile(r"^\s*\*/")

ROWS_FALLBACK = {
    36: [12, 12, 12, 6],
    38: [10, 10, 12, 6],
    42: [13, 15, 14, 6],
}


def parse_layout_shapes(lines: list[str]) -> dict[int, list[int]]:
    shapes: dict[int, list[int]] = {}
    i = 0
    while i < len(lines):
        m = LAYOUT_START_RE.search(lines[i])
        if m:
            suffix = int(m.group(1))
            rows: list[int] = []
            i += 1
            while i < len(lines):
                if LAYOUT_END_RE.match(lines[i]):
                    break
                rm = LAYOUT_ROW_RE.match(lines[i])
                if rm:
                    count = rm.group(2).count("_")
                    if count:
                        rows.append(count)
                i += 1
            if rows:
                shapes[suffix] = rows
        i += 1
    return shapes


def find_macro(lines: list[str], suffix: int) -> tuple[int, int, list[str]]:
    """Find the first GRAPHITE_BASE_<suffix> macro.

    Returns (start_line, end_line, flat_tokens).
    Uses BASE layer — the canonical layout for position queries.
    """
    target = f"GRAPHITE_BASE_{suffix}"
    i = 0
    n = len(lines)
    while i < n:
        m = DEFINE_RE.match(lines[i])
        if m and m.group(1) == target:
            start = i
            raw_rows: list[str] = []
            cur = DEFINE_RE.sub("", lines[i], count=1)
            while True:
                stripped = cur.rstrip()
                cont = stripped.endswith("\\")
                if cont:
                    stripped = stripped[:-1]
                raw_rows.append(stripped)
                if not cont:
                    end = i
                    break
                i += 1
                if i >= n:
                    end = i - 1
                    break
                cur = lines[i]
            tokens: list[str] = []
            for r in raw_rows:
                tokens.extend(p.strip() for p in SPLIT_RE.split(r.strip()) if p.strip())
            return start, end, tokens
        i += 1
    raise ValueError(f"macro {target} not found in file")


def find_all_macros_for_suffix(lines: list[str], suffix: int) -> list[tuple[int, int, str, list[str]]]:
    """Find all GRAPHITE_*_<suffix> macros. Returns list of (start, end, name, tokens)."""
    results = []
    i = 0
    n = len(lines)
    while i < n:
        m = DEFINE_RE.match(lines[i])
        if m:
            name = m.group(1)
            sm = SUFFIX_RE.search(name)
            if sm and int(sm.group(1)) == suffix:
                start = i
                raw_rows: list[str] = []
                cur = DEFINE_RE.sub("", lines[i], count=1)
                while True:
                    stripped = cur.rstrip()
                    cont = stripped.endswith("\\")
                    if cont:
                        stripped = stripped[:-1]
                    raw_rows.append(stripped)
                    if not cont:
                        end = i
                        break
                    i += 1
                    if i >= n:
                        end = i - 1
                        break
                    cur = lines[i]
                tokens: list[str] = []
                for r in raw_rows:
                    tokens.extend(p.strip() for p in SPLIT_RE.split(r.strip()) if p.strip())
                results.append((start, end, name, tokens))
        i += 1
    return results


def rebuild_macro(name: str, tokens: list[str], row_counts: list[int], col_width: int) -> list[str]:
    """Re-emit a macro body from a flat token list."""
    out = [f"#define {name} \\"]
    idx = 0
    for r_i, count in enumerate(row_counts):
        row_tokens = tokens[idx:idx + count]
        idx += count
        line = "".join(t.ljust(col_width) for t in row_tokens).rstrip()
        sep = " \\" if r_i < len(row_counts) - 1 else ""
        out.append("   " + line + sep)
    return out


# ---------------------------------------------------------------------------
# Commands
# ---------------------------------------------------------------------------

def cmd_get(coord: Coord, lines: list[str], shapes: dict[int, list[int]]) -> int:
    row_counts = shapes.get(coord.layout) or ROWS_FALLBACK.get(coord.layout)
    if row_counts is None:
        print(f"error: unknown layout {coord.layout}", file=sys.stderr)
        return 1
    try:
        _, _, tokens = find_macro(lines, coord.layout)
        idx = coord_to_index(coord, row_counts)
        print(tokens[idx])
        return 0
    except (ValueError, IndexError) as e:
        print(f"error: {e}", file=sys.stderr)
        return 1


def cmd_set(coord: Coord, binding: str, lines: list[str], shapes: dict[int, list[int]]) -> tuple[int, list[str]]:
    row_counts = shapes.get(coord.layout) or ROWS_FALLBACK.get(coord.layout)
    if row_counts is None:
        print(f"error: unknown layout {coord.layout}", file=sys.stderr)
        return 1, lines

    try:
        flat_idx = coord_to_index(coord, row_counts)
    except ValueError as e:
        print(f"error: {e}", file=sys.stderr)
        return 1, lines

    macros = find_all_macros_for_suffix(lines, coord.layout)
    if not macros:
        print(f"error: no GRAPHITE_*_{coord.layout} macros found", file=sys.stderr)
        return 1, lines

    col_width = max(
        max(len(t) for t in tokens) for _, _, _, tokens in macros
    ) + 2
    col_width = max(col_width, len(binding) + 2)

    # Patch token at flat_idx in every macro sharing this layout.
    new_lines = list(lines)
    offset = 0
    for start, end, name, tokens in macros:
        tokens = list(tokens)
        tokens[flat_idx] = binding
        rebuilt = rebuild_macro(name, tokens, row_counts, col_width)
        new_lines[start + offset:end + offset + 1] = rebuilt
        offset += len(rebuilt) - (end - start + 1)

    return 0, new_lines


# ---------------------------------------------------------------------------
# CLI
# ---------------------------------------------------------------------------

def parse_coord(args) -> Coord:
    return Coord(layout=args.layout, row=args.row, col=args.col)


def main() -> int:
    import argparse

    parser = argparse.ArgumentParser(description="Query or set ZMK keymap bindings by position")
    parser.add_argument("command", choices=["get", "set"])
    parser.add_argument("--layout", type=int, required=True)
    parser.add_argument("--row", type=int, required=True)
    parser.add_argument("--col", type=int, required=True)
    parser.add_argument("binding", nargs="?", help="Binding to set (required for 'set')")
    parser.add_argument("--file", "-f", help="dtsi file (defaults to stdin/stdout)")

    args = parser.parse_args()

    if args.command == "set" and not args.binding:
        parser.error("'set' requires a binding argument")

    if args.file:
        with open(args.file) as f:
            lines = f.read().splitlines()
    else:
        lines = sys.stdin.read().splitlines()

    shapes = parse_layout_shapes(lines)
    coord = parse_coord(args)

    if args.command == "get":
        return cmd_get(coord, lines, shapes)

    rc, new_lines = cmd_set(coord, args.binding, lines, shapes)
    if rc != 0:
        return rc

    out = "\n".join(new_lines) + "\n"
    if args.file:
        with open(args.file, "w") as f:
            f.write(out)
    else:
        sys.stdout.write(out)
    return 0


if __name__ == "__main__":
    sys.exit(main())
