return {
  {
    "omacom/aether.nvim",
    branch = "v3",
    name = "aether",
    priority = 1000,
    opts = {
      colors = {
        bg = "#fafafa",
        dark_bg = "#ececec",
        darker_bg = "#dedede",
        lighter_bg = "#f5f5f5",

        fg = "#212121",
        dark_fg = "#757575",
        light_fg = "#424242",
        bright_fg = "#000000",
        muted = "#9e9e9e",

        red = "#c900c4",
        yellow = "#026fde",
        orange = "#026fde",
        green = "#4a2fd0",
        cyan = "#0c67de",
        blue = "#3264eb",
        magenta = "#8a4ad7",
        brown = "#013a6f",

        bright_red = "#f930fb",
        bright_yellow = "#358fff",
        bright_green = "#9f85e0",
        bright_cyan = "#3986ff",
        bright_blue = "#5482ff",
        bright_magenta = "#b363ff",

        accent = "#3264eb",
        cursor = "#000000",
        foreground = "#212121",
        background = "#fafafa",
        selection = "#d0d0d0",
        selection_foreground = "#000000",
        selection_background = "#d0d0d0",
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
