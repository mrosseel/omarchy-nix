return {
  {
    "omacom/aether.nvim",
    branch = "v3",
    name = "aether",
    priority = 1000,
    opts = {
      colors = {
        bg = "#142620",
        dark_bg = "#0f1e19",
        darker_bg = "#0a1713",
        lighter_bg = "#203b31",

        fg = "#dfede5",
        dark_fg = "#91ad9f",
        light_fg = "#bed6c9",
        bright_fg = "#f0faf4",
        muted = "#64887b",

        red = "#d88d91",
        yellow = "#c5cc91",
        orange = "#d2ab8d",
        green = "#8bcbb1",
        cyan = "#86c7c5",
        blue = "#96b7d0",
        magenta = "#b7a1c8",
        brown = "#7e8970",

        bright_red = "#e6a6aa",
        bright_yellow = "#dce1ac",
        bright_green = "#a7dfc5",
        bright_cyan = "#a2dcda",
        bright_blue = "#b0cde3",
        bright_magenta = "#cfbce0",

        accent = "#8bcbb1",
        cursor = "#f0faf4",
        foreground = "#dfede5",
        background = "#142620",
        selection = "#2b5147",
        selection_foreground = "#f0faf4",
        selection_background = "#2b5147",
      },
    },
  },
  {
    "LazyVim/LazyVim",
    opts = {
      colorscheme = "aether",
    },
  },
}
