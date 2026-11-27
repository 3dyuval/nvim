;; Registers 9 Snacks picker sources (searxng, searxng_engines,
;; searxng_images, searxng_videos, searxng_news, searxng_files,
;; searxng_autocomplete, searxng_categories, searxng_packages) reachable from
;; the picker-of-pickers (<leader><leader>). Needs a SearXNG backend at
;; base_url. mapping {} disables its keymaps (they collide with Kitty's
;; <leader>rs / <leader>rR) — use the picker instead.
{1 "3dyuval/searxng.nvim"
 :enabled false
 :dependencies ["folke/snacks.nvim"]
 :event "VeryLazy"
 :opts {:mapping {:prompt false
                  :word false
                  :visual false
                  :engines false
                  :reload false}}}
