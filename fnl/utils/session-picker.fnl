(local Session {})

(fn Session.new [filename session-name]
  "Create session object from auto-session data

  Args:
    filename: encoded filename from f.file_name (e.g., webnew%2Ftableheaders.vim)
    session-name: decoded name from f.session_name (e.g., webnew/tableheaders)

  Lifecycle: filename is source of truth for file lookup, session-name for restore"
  (let [pipe-idx (string.find session-name "|")
        path (if pipe-idx
                 (string.sub session-name 1 (- pipe-idx 1))
                 session-name)
        branch (if pipe-idx
                   (string.sub session-name (+ pipe-idx 1))
                   "main")]
    {:_filename filename
     :_session_name session-name
     :_path path
     :_branch branch}))

(fn Session.path [self]
  "Get decoded path (without extension, without branch)"
  self._path)

(fn Session.branch [self]
  "Get branch name (defaults to 'main' if not in filename)"
  self._branch)

(fn Session.filename [self]
  "Get original percent-encoded filename with .vim extension"
  self._filename)

(fn Session.decoded [self]
  "Get decoded format for AutoSession restore: path|branch"
  (.. self._path "|" self._branch))

(fn Session.display-name [self]
  "Get folder name for UI display"
  (or (string.match self._path "[^/]+$") self._path))

(fn Session.picker-item [self]
  "Convert to Snacks picker item format"
  (let [display (Session.display-name self)
        preview-text (Session.preview self)]
    {:text (.. "  󰁯 " display " (" self._branch ") [" self._path "]")
     :path self._path
     :branch self._branch
     :session_name (Session.decoded self)
     :filename self._filename
     :display_name display
     :file self._path
     :_session self
     :preview {:text preview-text :ft "text"}}))

(fn Session.get-files [self]
  "Extract opened files from session file"
  (let [session-dir (.. (vim.fn.stdpath :data) "/sessions/")
        session-file (.. session-dir self._filename)
        files []]
    (when (vim.fn.filereadable session-file)
      (each [line (io.lines session-file)]
        (let [(line-num match-file) (string.match line "^badd%s+%+(%d+)%s+(.+)$")]
          (when line-num
            (table.insert files {:file match-file :line (tonumber line-num)})))))
    files))

(fn Session.preview [self]
  "Generate preview text with path, branch, and opened files"
  (let [files (Session.get-files self)
        lines [(.. "Path: " (Session.path self))
               (.. "Branch: " (Session.branch self))]]
    (if (> (length files) 0)
        (do
          (table.insert lines "")
          (table.insert lines "Files:")
          (each [_ f (ipairs files)]
            (table.insert lines (.. "  " f.file " +" f.line))))
        (table.insert lines "(no files in session)"))
    (table.concat lines "\n")))

(fn Session.restore [self]
  "Restore session using AutoSession API"
  (let [(ok auto-session) (pcall require :auto-session)]
    (when ok
      ;; autosave_and_restore expects the decoded session name (path|branch or just path)
      ;; which is what f.session_name gives us from get_session_list
      (auto-session.autosave_and_restore self._session_name))))

(fn build-session-items []
  "Build session items from auto-session library"
  (let [(ok auto-session) (pcall require :auto-session)]
    (if (not ok)
        []
        (let [Lib (require :auto-session.lib)
              root-dir (auto-session.get_root_dir)
              items []]
          (each [_ f (ipairs (Lib.get_session_list root-dir))]
            (when (and f f.file_name)
              (local session (Session.new f.file_name f.session_name))
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
                           ;; Close picker after restore completes
                           (vim.defer_fn (fn [] (picker:close)) 100)))}))))

{: open : Session}
