(fn build-session-items []
  "Build session items from auto-session library"
  (let [(ok auto-session) (pcall require :auto-session)]
    (if (not ok)
        []
        (let [Lib (require :auto-session.lib)
              root-dir (auto-session.get_root_dir)
              items []]
          (each [_ f (ipairs (Lib.get_session_list root-dir))]
            (when (and f f.session_name)
              (local decoded-name f.session_name)
              (when (string.find decoded-name "/")
                (local pipe-idx (string.find decoded-name "|"))
                (local session-path-part
                  (if pipe-idx
                      (string.sub decoded-name 1 (- pipe-idx 1))
                      decoded-name))
                (when (string.find session-path-part "^/")
                  (local branch-name
                    (if pipe-idx
                        (string.sub decoded-name (+ pipe-idx 1))
                        "main"))
                  (local display-name
                    (or (string.match session-path-part "[^/]+$") session-path-part))
                  (table.insert items
                    {:text (.. "  󰁯 " display-name " (" branch-name ") [" session-path-part "]")
                     :path session-path-part
                     :branch branch-name
                     :session_name f.session_name
                     :display_name display-name
                     :file session-path-part})))))  ;; Add file property so Snacks won't error on copy action
          items))))

(fn open []
  "Open the session picker"
  (let [snacks (require :snacks)
        items (build-session-items)]
    (if (= (length items) 0)
        (vim.notify "No sessions found" vim.log.levels.WARN)
        (snacks.picker
          {:title "Sessions"
           :items items
           :format "text"
           :on_confirm (fn [picker item]
                         (when (and item item.session_name)
                           (vim.cmd (.. ":AutoSession restore " item.session_name))
                           (picker:close)))
           :preview (fn [item]
                      (.. "Path: " item.path "\n"
                          "Branch: " item.branch "\n"
                          "Session: " item.session_name))}))))

{: open}
