;; opts {} is required — scratch.nvim registers its :Scratch* user commands
;; inside setup(), which lazy only calls when a spec has opts/config.
{1 "reybits/scratch.nvim"
 :lazy true
 :cmd ["ScratchToggle" "ScratchIssues" "ScratchTask"]
 :keys [{1 "<leader>Sc" 2 "<cmd>ScratchToggle<cr>" :desc "Scratch: toggle note"}
        {1 "<leader>Si" 2 "<cmd>ScratchIssues<cr>" :desc "Scratch: issues"}
        {1 "<leader>St" 2 "<cmd>ScratchTask<cr>" :desc "Scratch: new task"}]
 :opts {}}
