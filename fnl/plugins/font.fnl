(local FONT (or vim.env.TERM_FONT :monaspace))

(local fonts {
  :monaspace {
    :normal     "Monaspace Neon"
    :italic     "Monaspace Radon"
    :bold       "Monaspace Argon"
    :mono       "Monaspace Xenon"
    :size       13
  }
  :ioskeleymono {
    :normal     "Ioskeley Mono Regular"
    :italic     "Iosevka Curly"
    :bold       "Ioskeley Mono Bold"
    :mono       "Ioskeley Mono Regular"
    :size       13
  }
  :iosevka  {
    :normal     "Iosevka"
    :bold       "Iosevka Slab"
    :italic     "Iosevka Curly"
    :mono       "Iosevka Curly Slab"
    :size       13
  }
})

(local selected (. fonts FONT))

(if (= (vim.fn.has "gui_running") 1)
    (= vim.o.guifont (string.format "%s:h%d" selected.normal selected.size)))

{1 "jackplus-xyz/monaspace.nvim"
  :enabled true
  :lazy false
  :opts {:style_map {:italic [:LensLine :LensLineZero :LensLineLow :LensLineHigh :LensLineComplexity]}}}
