-- [nfnl] fnl/plugins/codelens.fnl
local function _1_()
  require("colortweak.tweak").hl({LensLine = {"Comment", {l = 0.9}}, LensLineZero = {"DiagnosticWarn", {l = 9}}, LensLineLow = {"DiagnosticHint", {l = 0.9}}, LensLineHigh = {"DiagnosticInfo", {l = 0.9}}, LensLineComplexity = {"DiagnosticWarn", {l = 0.9}}})
  local refs_provider
  local function _2_(bufnr, func_info, _provider_config, callback)
    local utils = require("lensline.utils")
    local function _3_(references)
      if references then
        local count = #references
        local function _4_()
          if (count == 0) then
            return {(utils.if_nerdfont_else("\243\176\140\184 ", "") .. " No references"), "LensLineZero"}
          elseif (count == 1) then
            return {(utils.if_nerdfont_else("\243\176\140\183 ", "") .. count .. " references"), "LensLineLow"}
          else
            return {(utils.if_nerdfont_else("", "") .. count .. " references"), "LensLineHigh"}
          end
        end
        local _let_5_ = _4_()
        local text = _let_5_[1]
        local hl = _let_5_[2]
        return callback({line = func_info.line, text = text, highlight = hl})
      else
        return callback(nil)
      end
    end
    return utils.get_lsp_references(bufnr, func_info, _3_)
  end
  refs_provider = {name = "references_with_warning", enabled = true, event = {"LspAttach", "BufWritePost"}, handler = _2_}
  local complexity_provider
  local function _7_(bufnr, func_info, _provider_config, callback)
    local utils = require("lensline.utils")
    local lines = utils.get_function_lines(bufnr, func_info)
    if (not lines or (#lines == 0)) then
      return callback(nil)
    else
      local code = table.concat(lines, "\n")
      local patterns = {"if%s", "elseif%s", "else%s", "for%s", "while%s", "repeat%s", "and%s", "or%s", "switch", "case%s", "try", "catch", "finally", "%?", "&&", "||"}
      local score = 1
      for _, pattern in ipairs(patterns) do
        for _0 in code:gmatch(pattern) do
          score = (score + 1)
        end
      end
      local function _8_()
        if (score <= 3) then
          return {utils.if_nerdfont_else("\243\176\148\182 ", ""), "simple", "LensLineLow"}
        elseif (score <= 8) then
          return {utils.if_nerdfont_else("\243\176\148\183 ", ""), "moderate", "LensLine"}
        elseif (score <= 15) then
          return {utils.if_nerdfont_else("\243\176\148\184 ", ""), "complex", "LensLineHigh"}
        else
          return {utils.if_nerdfont_else("\243\176\128\166 ", "!"), "very complex", "LensLineComplexity"}
        end
      end
      local _let_9_ = _8_()
      local icon = _let_9_[1]
      local label = _let_9_[2]
      local hl = _let_9_[3]
      return callback({line = func_info.line, text = (icon .. score .. " " .. label), highlight = hl})
    end
  end
  complexity_provider = {name = "complexity_score", enabled = true, event = {"BufWritePost", "TextChanged"}, handler = _7_}
  local style = {highlight = "LensLine", placement = "inline", prefix = ""}
  return require("lensline").setup({profiles = {{name = "default", style = style, providers = {refs_provider, complexity_provider}}, {name = "complexity", style = style, providers = {complexity_provider}}, {name = "references", style = style, providers = {refs_provider}}}})
end
return {"oribarilan/lensline.nvim", event = "LspAttach", dependencies = {"3dyuval/colortweak.nvim"}, config = _1_}
