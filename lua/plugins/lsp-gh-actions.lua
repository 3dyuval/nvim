vim.filetype.add({
  pattern = {
    [".*/%.github/workflows/.*%.ya?ml"] = "yaml.github",
  },
})

local function get_init_options()
  local gh = require("octo.gh")

  local token = gh.auth.token({ opts = { mode = "sync" } })
  token = token and token:gsub("%s+$", "")

  local stdout = gh.repo.view({
    json = "id,owner,name",
    opts = { mode = "sync" },
  })

  local repo_info = {}
  if stdout and stdout ~= "" then
    local ok, data = pcall(vim.json.decode, stdout)
    if ok and type(data) == "table" then
      repo_info = {
        id = data.id,
        owner = data.owner.login,
        name = data.name,
        workspaceUri = "file://" .. vim.fn.getcwd(),
        organizationOwned = data.owner.type == "Organization",
      }
    end
  end

  return {
    sessionToken = token,
    repos = { repo_info },
  }
end

return {
  "neovim/nvim-lspconfig",
  opts = {
    servers = {
      gh_actions_ls = {},
    },
    setup = {
      gh_actions_ls = function()
        vim.api.nvim_create_autocmd("FileType", {
          pattern = "yaml.github",
          callback = function(args)
            local root_dir = vim.fs.dirname(vim.api.nvim_buf_get_name(args.buf))
            if not vim.endswith(root_dir, "/.github/workflows") then
              return
            end

            vim.lsp.start({
              name = "gh_actions_ls",
              cmd = { "gh-actions-language-server", "--stdio" },
              root_dir = root_dir,
              init_options = get_init_options(),
              handlers = {
                ["actions/readFile"] = function(_, result)
                  if type(result.path) ~= "string" then
                    return nil, { code = -32602, message = "Invalid path parameter" }
                  end
                  local file_path = vim.uri_to_fname(result.path)
                  if vim.fn.filereadable(file_path) == 1 then
                    local f = assert(io.open(file_path, "r"))
                    local text = f:read("*a")
                    f:close()
                    return text, nil
                  else
                    return nil, { code = -32603, message = "File not found: " .. file_path }
                  end
                end,
              },
            })
          end,
        })
        return true -- skip default lspconfig setup
      end,
    },
  },
}
