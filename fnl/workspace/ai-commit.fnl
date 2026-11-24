;; :AiCommit — AI commit popup (default / --preview|-p / --repeat|-r).
(let [ai-popup (require :utils.ai_popup)]
  (vim.api.nvim_create_user_command
    :AiCommit
    (fn [opts]
      (if (or (= opts.args :--preview) (= opts.args :-p))
          (ai-popup.run_generate (or vim.g.AiCommitLastSettings {}))
          (or (= opts.args :--repeat) (= opts.args :-r))
          (ai-popup.repeat_last)
          (ai-popup.create)))
    {:nargs "?" :desc "AI commit popup"}))

{}
