return {
  "oribarilan/lensline.nvim",
  event = "LspAttach",
  config = function()
    require("colortweak.tweak").hl({ --  uses "3dyuval/colortweak"
      LensLine = { "Comment", { l = 1.2, s = 1.5 } },
      LensLineZero = { "DiagnosticWarn", { l = 0.9, s = 1.5 } },
      LensLineLow = { "DiagnosticHint", { l = 1.0, s = 2 } },
      LensLineHigh = { "DiagnosticInfo", { l = 1.3, s = 2, h = -30 } },
      LensLineComplexity = { "DiagnosticWarn", { l = 1.1, s = 2, h = 90 } },
    })

    require("lensline").setup({
      profiles = {
        {
          name = "default",
          style = {
            highlight = "LensLine",
            placement = "inline",
            prefix = "",
          },
          providers = {
            {
              name = "references_with_warning",
              enabled = true,
              event = { "LspAttach", "BufWritePost" },
              handler = function(bufnr, func_info, provider_config, callback)
                local utils = require("lensline.utils")

                utils.get_lsp_references(bufnr, func_info, function(references)
                  if references then
                    local count = #references
                    local text

                    if count == 0 then
                      text = utils.if_nerdfont_else("󰌸 ", "") .. " No references"
                    elseif count == 1 then
                      text = utils.if_nerdfont_else("󰌷 ", "") .. count .. " references"
                    else
                      text = utils.if_nerdfont_else("", "") .. count .. " references"
                    end

                    callback({ line = func_info.line, text = text })
                  else
                    callback(nil)
                  end
                end)
              end,
            },
            {
              name = "complexity_score",
              enabled = true,
              event = { "BufWritePost", "TextChanged" },
              handler = function(bufnr, func_info, provider_config, callback)
                local utils = require("lensline.utils")
                local lines = utils.get_function_lines(bufnr, func_info)
                if not lines or #lines == 0 then
                  callback(nil)
                  return
                end

                local code = table.concat(lines, "\n")
                local score = 1 -- base complexity

                -- Count decision points
                local patterns = {
                  "if%s",
                  "elseif%s",
                  "else%s",
                  "for%s",
                  "while%s",
                  "repeat%s",
                  "and%s",
                  "or%s",
                  "switch",
                  "case%s",
                  "try",
                  "catch",
                  "finally",
                  "%?", -- ternary
                  "&&",
                  "||",
                }

                for _, pattern in ipairs(patterns) do
                  for _ in code:gmatch(pattern) do
                    score = score + 1
                  end
                end

                local icon, label
                if score <= 3 then
                  icon = utils.if_nerdfont_else("󰔶 ", "")
                  label = "simple"
                elseif score <= 8 then
                  icon = utils.if_nerdfont_else("󰔷 ", "")
                  label = "moderate"
                elseif score <= 15 then
                  icon = utils.if_nerdfont_else("󰔸 ", "")
                  label = "complex"
                else
                  icon = utils.if_nerdfont_else("󰀦 ", "!")
                  label = "very complex"
                end

                callback({
                  line = func_info.line,
                  text = icon .. score .. " " .. label,
                })
              end,
            },
          },
        },
      },
    })
  end,
}
