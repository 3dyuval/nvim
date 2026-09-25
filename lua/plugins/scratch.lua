-- [nfnl] fnl/plugins/scratch.fnl
return {"reybits/scratch.nvim", lazy = true, cmd = {"ScratchToggle", "ScratchIssues", "ScratchTask"}, keys = {{"<leader>Sc", "<cmd>ScratchToggle<cr>", desc = "Scratch: toggle note"}, {"<leader>Si", "<cmd>ScratchIssues<cr>", desc = "Scratch: issues"}, {"<leader>St", "<cmd>ScratchTask<cr>", desc = "Scratch: new task"}}, opts = {}}
