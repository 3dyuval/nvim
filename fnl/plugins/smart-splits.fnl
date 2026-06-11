;; smart-splits.nvim — window nav (Ctrl) and resize (Ctrl+Alt) across nvim
;; splits AND kitty splits, using the HAEI layout (h/a/e/i = left/down/up/right).
;; Kitty passes these keys through to nvim when focused (var:IS_NVIM unset in
;; ~/.config/kitty/omarkit.conf); at the split edge smart-splits hands off to the
;; neighboring kitty split via its kitty integration. It never touches the WM.
{1 "mrjones2014/smart-splits.nvim"
 :lazy false
 :opts {:at_edge "stop"
        :multiplexer_integration "kitty"}
 :keys
 [;; navigation
  {1 "<C-h>" 2 (fn [] ((. (require :smart-splits) :move_cursor_left)))  :desc "Window left"}
  {1 "<C-a>" 2 (fn [] ((. (require :smart-splits) :move_cursor_down)))  :desc "Window down"}
  {1 "<C-e>" 2 (fn [] ((. (require :smart-splits) :move_cursor_up)))    :desc "Window up"}
  {1 "<C-i>" 2 (fn [] ((. (require :smart-splits) :move_cursor_right))) :desc "Window right"}
  ;; resize (Ctrl+Alt)
  {1 "<C-M-h>" 2 (fn [] ((. (require :smart-splits) :resize_left)))  :desc "Resize left"}
  {1 "<C-M-a>" 2 (fn [] ((. (require :smart-splits) :resize_down)))  :desc "Resize down"}
  {1 "<C-M-e>" 2 (fn [] ((. (require :smart-splits) :resize_up)))    :desc "Resize up"}
  {1 "<C-M-i>" 2 (fn [] ((. (require :smart-splits) :resize_right))) :desc "Resize right"}]}
