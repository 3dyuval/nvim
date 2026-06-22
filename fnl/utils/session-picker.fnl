(local Session {})

(fn Session.decode [encoded-name]
  "Decode URL-encoded session name to path|branch format"
  (-> encoded-name
      (string.gsub "%%2F" "/")
      (string.gsub "%%2f" "/")
      (string.gsub "%%7C" "|")
      (string.gsub "%%7c" "|")))

(fn Session.parse [session-name]
  "Parse session_name into {path branch encoded_name}"
  (let [decoded (Session.decode session-name)
        pipe-idx (string.find decoded "|")
        path (if pipe-idx
                 (string.sub decoded 1 (- pipe-idx 1))
                 decoded)
        branch (if pipe-idx
                   (string.sub decoded (+ pipe-idx 1))
                   "main")]
    {:path path :branch branch :encoded_name session-name}))

(fn Session.display-name [path]
  "Extract display name from full path"
  (or (string.match path "[^/]+$") path))

(fn Session.picker-item [session]
  "Convert session to picker item format"
  (let [display (Session.display-name session.path)
        decoded-session-name (.. session.path "|" session.branch)]
    {:text (.. "  󰁯 " display " (" session.branch ") [" session.path "]")
     :path session.path
     :branch session.branch
     :session_name decoded-session-name
     :encoded_name session.encoded_name
     :display_name display
     :file session.path
     :_session session}))

(fn Session.restore [session]
  "Restore session using AutoSession API"
  (let [(ok auto-session) (pcall require :auto-session)]
    (when ok
      (let [decoded-name (.. session.path "|" session.branch)]
        (auto-session.autosave_and_restore decoded-name)))))

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
              (local session (Session.parse f.session_name))
              (table.insert items (Session.picker-item session))))
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
                         (when (and item item._session)
                           (Session.restore item._session)
                           (picker:close)))
           :preview (fn [item]
                      (.. "Path: " item.path "\n"
                          "Branch: " item.branch "\n"
                          "Session: " item.session_name))}))))

{: open}
