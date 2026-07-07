(local {: register} (require :config.keymaps.register))

(local tree
  { :<leader>a
   {:group "AI/Claude"
    :c {:cmd ":ClaudeCode<CR>"            :desc "Toggle Claude Code"}
    :f {:cmd ":ClaudeCodeFocus<CR>"       :desc "Focus Claude Code"}
    :r {:cmd ":ClaudeCode --resume<CR>"   :desc "Resume session"}
    :C {:cmd ":ClaudeCode --continue<CR>" :desc "Continue last session"}
    :m {:cmd ":ClaudeCodeSelectModel<CR>" :desc "Select model"}
    :p {:cmd ":ClaudeCodeAdd %<CR>"       :desc "Add current file to context"}
    :s {:cmd ":ClaudeCodeSend<CR>"        :desc "Send selection"}
    :a {:cmd ":ClaudeCodeDiffAccept<CR>"  :desc "Accept diff"}
    :d {:cmd ":ClaudeCodeDiffDeny<CR>"    :desc "Deny diff"}}})

(register "" tree)
