(local Session {})

(fn Session.new [encoded-filename]
  "Create session object from percent-encoded filename

  Accepts: %2Fhome%2Fyuv%2Fgc%2Fweb%7Cmain.vim or webnew%2Ftableheaders.vim
  Stores: path, branch, and encoded representation for bidirectional access"
  (let [decoded (-> encoded-filename
                    (string.gsub "%%2F" "/")
                    (string.gsub "%%2f" "/")
                    (string.gsub "%%7C" "|")
                    (string.gsub "%%7c" "|"))
        pipe-idx (string.find decoded "|")
        path-with-ext (if pipe-idx
                          (string.sub decoded 1 (- pipe-idx 1))
                          decoded)
        path (string.gsub path-with-ext "%.vim$" "")
        branch (if pipe-idx
                   (string.sub decoded (+ pipe-idx 1))
                   "main")]
    {:_path path
     :_branch branch
     :_encoded encoded-filename}))

(fn Session.path [self]
  "Get decoded path (without extension, without branch)"
  self._path)

(fn Session.branch [self]
  "Get branch name (defaults to 'main' if not in filename)"
  self._branch)

(fn Session.encoded [self]
  "Get original percent-encoded filename"
  self._encoded)

(fn Session.decoded [self]
  "Get decoded format for AutoSession restore: path|branch"
  (.. self._path "|" self._branch))

(fn Session.display-name [self]
  "Get folder name for UI display"
  (or (string.match self._path "[^/]+$") self._path))

(fn Session.picker-item [self]
  "Convert to Snacks picker item format"
  (let [display (Session.display-name self)]
    {:text (.. "  󰁯 " display " (" self._branch ") [" self._path "]")
     :path self._path
     :branch self._branch
     :session_name (Session.decoded self)
     :encoded_name self._encoded
     :display_name display
     :file self._path
     :_session self}))

(fn Session.get-files [self]
  "Extract opened files from session file"
  (let [session-dir (.. (vim.fn.stdpath :data) "/sessions/")
        session-file (.. session-dir (Session.encoded self))
        files []]
    (when (vim.fn.filereadable session-file)
      (each [line (io.lines session-file)]
        (let [(line-num match-file) (string.match line "^badd%s+%+(%d+)%s+(.+)$")]
          (when line-num
            (table.insert files {:file match-file :line (tonumber line-num)})))))
    files))

(fn Session.restore [self]
  "Restore session using AutoSession API"
  (let [(ok auto-session) (pcall require :auto-session)]
    (when ok
      (auto-session.autosave_and_restore (Session.decoded self)))))

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
              (local session (Session.new f.session_name))
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
                      (when (and item item._session item.path item.branch)
                        (let [session item._session
                              files (Session.get-files session)
                              files-text (if (> (length files) 0)
                                            (.. "\nFiles:\n"
                                                (table.concat (icollect [_ f (ipairs files)]
                                                                (.. "  " f.file " +" f.line))
                                                              "\n"))
                                            "")]
                          (.. "Path: " item.path "\n"
                              "Branch: " item.branch
                              files-text))))}))))

{: open : Session}
