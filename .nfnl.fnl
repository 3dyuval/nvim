;; nfnl configuration for nvim config
;; Compiles fnl/**/*.fnl to lua/**/*.lua on save

{;; Only compile files under fnl/ directory (not root .fnl files)
 :source-file-patterns ["fnl/**/*.fnl"]

 ;; Verbose mode for debugging (set to false once working)
 :verbose false

 ;; Enable protective header comments
 :header-comment true

 ;; Auto-detect orphaned .lua files
 :orphan-detection {:auto? true
                    :ignore-patterns []}}
