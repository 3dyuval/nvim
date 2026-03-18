--- blink.cmp source for jq filters and builtins
--- Activates when the current line contains "jq"

local M = {}

local builtins = {
  -- Core filters
  { label = ".", detail = "Identity" },
  { label = ".[]", detail = "Iterate array/object values" },
  { label = ".key", detail = "Object field access" },
  { label = ".[0]", detail = "Array index" },
  { label = ".[0:3]", detail = "Array slice" },
  { label = ".[]?", detail = "Optional iterate (no error on non-iterable)" },
  { label = ".key?", detail = "Optional field access" },

  -- Types and conversion
  { label = "type", detail = "Value type as string" },
  { label = "length", detail = "Length of value" },
  { label = "keys", detail = "Object keys or array indices" },
  { label = "keys_unsorted", detail = "Object keys in original order" },
  { label = "values", detail = "Object values" },
  { label = "has(key)", detail = "Check if key exists", insertText = 'has("$1")', insertTextFormat = 2 },
  { label = "in(obj)", detail = "Check if input is key in obj" },
  { label = "to_entries", detail = "Object → [{key, value}...]" },
  { label = "from_entries", detail = "[{key, value}...] → object" },
  {
    label = "with_entries(f)",
    detail = "to_entries | map(f) | from_entries",
    insertText = "with_entries($1)",
    insertTextFormat = 2,
  },
  { label = "contains(other)", detail = "Deep containment check", insertText = "contains($1)", insertTextFormat = 2 },
  { label = "inside(other)", detail = "Inverse of contains", insertText = "inside($1)", insertTextFormat = 2 },

  -- Selection
  {
    label = "select(expr)",
    detail = "Keep values where expr is truthy",
    insertText = "select($1)",
    insertTextFormat = 2,
  },
  { label = "empty", detail = "Produce no output" },
  { label = "error", detail = "Raise error" },
  { label = "error(msg)", detail = "Raise error with message", insertText = 'error("$1")', insertTextFormat = 2 },

  -- Array/object ops
  { label = "map(f)", detail = "Apply f to each element", insertText = "map($1)", insertTextFormat = 2 },
  { label = "map_values(f)", detail = "Apply f to each value", insertText = "map_values($1)", insertTextFormat = 2 },
  { label = "add", detail = "Sum/concat array elements" },
  { label = "any", detail = "True if any element is truthy" },
  { label = "any(f)", detail = "True if any element satisfies f", insertText = "any($1)", insertTextFormat = 2 },
  { label = "all", detail = "True if all elements are truthy" },
  { label = "all(f)", detail = "True if all elements satisfy f", insertText = "all($1)", insertTextFormat = 2 },
  { label = "flatten", detail = "Flatten nested arrays" },
  { label = "flatten(depth)", detail = "Flatten to depth", insertText = "flatten($1)", insertTextFormat = 2 },
  { label = "range(n)", detail = "Generate 0..n-1", insertText = "range($1)", insertTextFormat = 2 },
  { label = "range(from;to)", detail = "Generate from..to-1", insertText = "range($1;$2)", insertTextFormat = 2 },
  { label = "floor", detail = "Round down" },
  { label = "ceil", detail = "Round up" },
  { label = "round", detail = "Round to nearest" },
  { label = "sqrt", detail = "Square root" },
  { label = "min", detail = "Minimum value" },
  { label = "max", detail = "Maximum value" },
  { label = "min_by(f)", detail = "Min by function", insertText = "min_by($1)", insertTextFormat = 2 },
  { label = "max_by(f)", detail = "Max by function", insertText = "max_by($1)", insertTextFormat = 2 },
  { label = "sort", detail = "Sort array" },
  { label = "sort_by(f)", detail = "Sort by function", insertText = "sort_by($1)", insertTextFormat = 2 },
  { label = "reverse", detail = "Reverse array" },
  { label = "unique", detail = "Remove duplicates" },
  { label = "unique_by(f)", detail = "Unique by function", insertText = "unique_by($1)", insertTextFormat = 2 },
  { label = "group_by(f)", detail = "Group by function", insertText = "group_by($1)", insertTextFormat = 2 },
  { label = "indices(s)", detail = "Indices of occurrences", insertText = "indices($1)", insertTextFormat = 2 },
  { label = "index(s)", detail = "First index of", insertText = "index($1)", insertTextFormat = 2 },
  { label = "rindex(s)", detail = "Last index of", insertText = "rindex($1)", insertTextFormat = 2 },
  { label = "first", detail = "First element" },
  { label = "last", detail = "Last element" },
  { label = "nth(n)", detail = "Nth element", insertText = "nth($1)", insertTextFormat = 2 },
  { label = "limit(n;f)", detail = "First n results of f", insertText = "limit($1;$2)", insertTextFormat = 2 },
  { label = "until(cond;update)", detail = "Loop until condition", insertText = "until($1;$2)", insertTextFormat = 2 },
  { label = "while(cond;update)", detail = "Loop while condition", insertText = "while($1;$2)", insertTextFormat = 2 },
  { label = "recurse", detail = "Recursively descend" },
  { label = "recurse(f)", detail = "Recursively apply f", insertText = "recurse($1)", insertTextFormat = 2 },
  { label = "transpose", detail = "Transpose array of arrays" },

  -- String ops
  { label = "ascii_downcase", detail = "Lowercase string" },
  { label = "ascii_upcase", detail = "Uppercase string" },
  { label = "ltrimstr(s)", detail = "Remove prefix", insertText = 'ltrimstr("$1")', insertTextFormat = 2 },
  { label = "rtrimstr(s)", detail = "Remove suffix", insertText = 'rtrimstr("$1")', insertTextFormat = 2 },
  { label = "startswith(s)", detail = "Check prefix", insertText = 'startswith("$1")', insertTextFormat = 2 },
  { label = "endswith(s)", detail = "Check suffix", insertText = 'endswith("$1")', insertTextFormat = 2 },
  { label = "split(s)", detail = "Split string", insertText = 'split("$1")', insertTextFormat = 2 },
  { label = "join(s)", detail = "Join array to string", insertText = 'join("$1")', insertTextFormat = 2 },
  { label = "test(regex)", detail = "Test regex match", insertText = 'test("$1")', insertTextFormat = 2 },
  { label = "match(regex)", detail = "Regex match details", insertText = 'match("$1")', insertTextFormat = 2 },
  { label = "capture(regex)", detail = "Named captures", insertText = 'capture("$1")', insertTextFormat = 2 },
  { label = "scan(regex)", detail = "All regex matches", insertText = 'scan("$1")', insertTextFormat = 2 },
  {
    label = "sub(regex;replacement)",
    detail = "Replace first match",
    insertText = 'sub("$1";"$2")',
    insertTextFormat = 2,
  },
  {
    label = "gsub(regex;replacement)",
    detail = "Replace all matches",
    insertText = 'gsub("$1";"$2")',
    insertTextFormat = 2,
  },
  { label = "tostring", detail = "Convert to string" },
  { label = "tonumber", detail = "Convert to number" },
  { label = "implode", detail = "Codepoints → string" },
  { label = "explode", detail = "String → codepoints" },
  { label = "tojson", detail = "Serialize to JSON string" },
  { label = "fromjson", detail = "Parse JSON string" },
  { label = "@base32", detail = "Base32 encode" },
  { label = "@base32d", detail = "Base32 decode" },
  { label = "@base64", detail = "Base64 encode" },
  { label = "@base64d", detail = "Base64 decode" },
  { label = "@html", detail = "HTML escape" },
  { label = "@uri", detail = "URI encode" },
  { label = "@csv", detail = "Format as CSV" },
  { label = "@tsv", detail = "Format as TSV" },
  { label = "@json", detail = "Format as JSON" },
  { label = "@text", detail = "Format as text" },

  -- Path ops
  { label = "path(expr)", detail = "Output paths to values", insertText = "path($1)", insertTextFormat = 2 },
  { label = "paths", detail = "All paths" },
  { label = "leaf_paths", detail = "Paths to leaf values" },
  { label = "getpath(path)", detail = "Get value at path", insertText = "getpath($1)", insertTextFormat = 2 },
  { label = "setpath(path;value)", detail = "Set value at path", insertText = "setpath($1;$2)", insertTextFormat = 2 },
  { label = "delpaths(paths)", detail = "Delete paths", insertText = "delpaths($1)", insertTextFormat = 2 },

  -- Reduce and foreach
  {
    label = "reduce",
    detail = "Reduce expression",
    insertText = "reduce .[] as $$item (${1:init}; ${2:update})",
    insertTextFormat = 2,
  },
  {
    label = "foreach",
    detail = "Foreach expression",
    insertText = "foreach .[] as $$item (${1:init}; ${2:update}; ${3:extract})",
    insertTextFormat = 2,
  },

  -- I/O and misc
  { label = "input", detail = "Read next input" },
  { label = "inputs", detail = "Read remaining inputs" },
  { label = "debug", detail = "Debug output to stderr" },
  { label = "debug(msg)", detail = "Debug with message", insertText = 'debug("$1")', insertTextFormat = 2 },
  { label = "env", detail = "Environment variables object" },
  { label = "env.KEY", detail = "Get environment variable", insertText = "env.$1", insertTextFormat = 2 },
  { label = "null", detail = "Null value" },
  { label = "true", detail = "Boolean true" },
  { label = "false", detail = "Boolean false" },
  { label = "not", detail = "Boolean negation" },
  { label = "if-then-else", detail = "Conditional", insertText = "if $1 then $2 else $3 end", insertTextFormat = 2 },
  { label = "try-catch", detail = "Error handling", insertText = "try $1 catch $2", insertTextFormat = 2 },
  {
    label = "label-break",
    detail = "Loop break",
    insertText = "label $$out | foreach .[] as $$x (0; . + $$x; if . > $1 then ., break $$out else . end)",
    insertTextFormat = 2,
  },
  { label = "def", detail = "Define function", insertText = "def $1: $2;", insertTextFormat = 2 },
  { label = "as", detail = "Bind variable", insertText = ". as $$${1:name} | $2", insertTextFormat = 2 },
  { label = "alternative //", detail = "Alternative operator", insertText = "// $1", insertTextFormat = 2 },
  { label = "update |=", detail = "Update operator", insertText = "|= $1", insertTextFormat = 2 },
}

local jq_flags = {
  { label = "-r", detail = "Raw output (no quotes)" },
  { label = "-R", detail = "Raw input (treat as strings)" },
  { label = "-c", detail = "Compact output" },
  { label = "-e", detail = "Exit status based on output" },
  { label = "-s", detail = "Slurp: read all inputs into array" },
  { label = "-S", detail = "Sort object keys" },
  { label = "-n", detail = "Null input" },
  { label = "-j", detail = "Join output (no newlines)" },
  { label = "--arg", detail = "Set variable", insertText = "--arg $1 $2", insertTextFormat = 2 },
  { label = "--argjson", detail = "Set JSON variable", insertText = "--argjson $1 $2", insertTextFormat = 2 },
  {
    label = "--slurpfile",
    detail = "Slurp file into variable",
    insertText = "--slurpfile $1 $2",
    insertTextFormat = 2,
  },
  { label = "--rawfile", detail = "Read raw file into variable", insertText = "--rawfile $1 $2", insertTextFormat = 2 },
  { label = "--jsonargs", detail = "Treat remaining args as JSON" },
  { label = "--args", detail = "Treat remaining args as strings" },
  { label = "--tab", detail = "Indent with tabs" },
  { label = "--indent", detail = "Indent with n spaces", insertText = "--indent $1", insertTextFormat = 2 },
  { label = "--from-file", detail = "Read filter from file", insertText = "--from-file $1", insertTextFormat = 2 },
}

-- Build items cache
local items = {}
for _, b in ipairs(builtins) do
  table.insert(items, {
    label = b.label,
    detail = b.detail,
    kind = 3, -- Function
    insertText = b.insertText,
    insertTextFormat = b.insertTextFormat,
  })
end
for _, f in ipairs(jq_flags) do
  table.insert(items, {
    label = f.label,
    detail = f.detail,
    kind = 6, -- Variable
    insertText = f.insertText,
    insertTextFormat = f.insertTextFormat,
  })
end

function M.new()
  return setmetatable({}, { __index = M })
end

function M:get_completions(ctx, callback)
  local shellutil = require("blink.sources.shellutil")
  if not shellutil.in_command(ctx, "jq") then
    callback({ is_incomplete_forward = false, is_incomplete_backward = false, items = {} })
    return
  end

  callback({
    is_incomplete_forward = false,
    is_incomplete_backward = false,
    items = items,
  })
end

return M
