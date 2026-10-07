;; nvim-platformio.lua — PlatformIO IDE workflow inside nvim (build/upload/
;; serial monitor/library management). Loads only when platformio.ini exists or
;; on :Pioinit, so it costs nothing outside embedded projects.
;;
;; LSP note: this plugin can auto-configure clangd (lsp = "clangd"), but our own
;; clangd setup in fnl/lsp/setup.fnl already owns the server config, root markers
;; (platformio.ini) and the --query-driver flag. Setting lsp = false here avoids a
;; second, conflicting clangd registration; we keep the plugin purely for its pio
;; command surface. Regenerate compile_commands.json with `pio run -t compiledb`.
;;
;; toggleterm is a hard dependency (foreground/background pio terminals); the
;; other README deps (treesitter, plenary, which-key, snacks) are already in this
;; config. picker_backend "snacks" reuses our existing picker instead of pulling
;; in telescope/mini.pick.
{1 "anurag3301/nvim-platformio.lua"
 :dependencies ["akinsho/toggleterm.nvim"]
 :cmd [:Pioinit
       :Piorun
       :Piocmdf
       :Piocmdh
       :Piolib
       :Piomon
       :Piodebug
       :PioTermList
       :PioLSP]
 :config (fn []
           (set vim.g.pioConfig {:lsp false
                                 :picker_backend :snacks
                                 :menu_key "<leader>\\"
                                 :debug false})
           (let [(ok platformio) (pcall require :platformio)]
             (when ok
               (platformio.setup vim.g.pioConfig))))}
