;; :BugTemplate / :BugSnippet — scaffold bug-report buffers.
(vim.api.nvim_create_user_command
  :BugTemplate
  (fn [opts] ((. (require :utils.buffers) :create_buffer_bug) (or opts.args :X)))
  {:nargs "?"})

(vim.api.nvim_create_user_command
  :BugSnippet
  (fn [opts] ((. (require :utils.buffers) :create_buffer_bug_snippet) (or opts.args :X)))
  {:nargs "?"})

{}
