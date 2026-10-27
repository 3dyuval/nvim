-- [nfnl] fnl/plugins/coerce.fnl
local function _1_()
  local coerce = require("coerce")
  local case_m = require("coerce.case")
  local register_case
  local function _2_(key, case_fn, desc)
    return coerce.register_case({keymap = key, case = case_fn, description = desc})
  end
  register_case = _2_
  register_case("L", vim.fn.tolower, "lowercase")
  register_case("U", vim.fn.toupper, "UPPERCASE")
  register_case("S", case_m.to_snake_case, "snake_case")
  register_case("K", case_m.to_kebab_case, "kebab-case")
  register_case("C", case_m.to_camel_case, "camelCase")
  register_case("P", case_m.to_pascal_case, "PascalCase")
  register_case("A", case_m.to_upper_case, "CONSTANT_CASE")
  register_case("D", case_m.to_dot_case, "dot.case")
  register_case("T", case_m.to_title_case, "Title Case")
  coerce.setup()
  vim.keymap.set("n", "gu", "<Plug>(coerce-normal)", {desc = "Coerce word"})
  return vim.keymap.set("v", "gu", "<Plug>(coerce-visual)", {desc = "Coerce selection"})
end
return {"gregorias/coerce.nvim", tag = "v5.0.0", event = "VeryLazy", config = _1_}
