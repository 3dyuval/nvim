{1 "3dyuval/gitgraph.nvim"
 :dev true
 :branch "feat/snacks-api"
 :opts {:git_cmd "git"
        :format {:timestamp "%H:%M:%S %d-%m-%Y"
                 :fields ["hash" "timestamp" "author" "branch_name" "tag"]}
        :symbols {:merge_commit (vim.fn.nr2char 0xF5FA)
                  :commit (vim.fn.nr2char 0xF5FB)
                  :merge_commit_end (vim.fn.nr2char 0xF5F6)
                  :commit_end (vim.fn.nr2char 0xF5F7)
                  :GVER (vim.fn.nr2char 0xF5D1)
                  :GHOR (vim.fn.nr2char 0xF5D0)
                  :GCLD (vim.fn.nr2char 0xF5D7)
                  :GCRD "╭"
                  :GCLU (vim.fn.nr2char 0xF5D9)
                  :GCRU (vim.fn.nr2char 0xF5D8)
                  :GLRU (vim.fn.nr2char 0xF5E5)
                  :GLRD (vim.fn.nr2char 0xF5E0)
                  :GLUD (vim.fn.nr2char 0xF5DE)
                  :GRUD (vim.fn.nr2char 0xF5DB)
                  :GFORKU (vim.fn.nr2char 0xF5E6)
                  :GFORKD (vim.fn.nr2char 0xF5E6)
                  :GRUDCD (vim.fn.nr2char 0xF5DB)
                  :GRUDCU (vim.fn.nr2char 0xF5DA)
                  :GLUDCD (vim.fn.nr2char 0xF5DE)
                  :GLUDCU (vim.fn.nr2char 0xF5DD)
                  :GLRDCL (vim.fn.nr2char 0xF5E0)
                  :GLRDCR (vim.fn.nr2char 0xF5E1)
                  :GLRUCL (vim.fn.nr2char 0xF5E3)
                  :GLRUCR (vim.fn.nr2char 0xF5E5)}}
 :config (fn [_ opts]
           ((. (require :gitgraph) :setup) opts)
           (let [link (fn [from to]
                        (vim.api.nvim_set_hl 0 from {:link to :default false}))
                 apply (fn []
                         (link :GitGraphBranch1 :Function)
                         (link :GitGraphBranch2 :Type)
                         (link :GitGraphBranch3 :String)
                         (link :GitGraphBranch4 :Identifier)
                         (link :GitGraphBranch5 :Special)
                         (link :GitGraphHash :Identifier)
                         (link :GitGraphTimestamp :Comment)
                         (link :GitGraphAuthor :Type)
                         (link :GitGraphBranchName :Function)
                         (link :GitGraphBranchTag :Constant)
                         (link :GitGraphBranchMsg :Normal))]
             (apply)
             (vim.api.nvim_create_autocmd :ColorScheme {:callback apply})))}
