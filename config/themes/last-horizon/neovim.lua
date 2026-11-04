return {
  {
    "omacom/aether.nvim",
    branch = "v3",
    name = "aether",
    priority = 1000,
    opts = {
      colors = {
        bg = "#0c0b0c",
        dark_bg = "#090809",
        darker_bg = "#060606",
        lighter_bg = "#0c0b0c",

        fg = "#FAFCFB",
        dark_fg = "#584e51",
        light_fg = "#cfd3cd",
        bright_fg = "#e2dddc",
        muted = "#584e51",

        red = "#c38b7b",
        yellow = "#6B5E73",
        orange = "#6B5E73",
        green = "#87a9b0",
        cyan = "#a5a0b6",
        blue = "#b59790",
        magenta = "#c4d8e2",
        brown = "#362f3a",

        bright_red = "#c38b7b",
        bright_yellow = "#6B5E73",
        bright_green = "#87a9b0",
        bright_cyan = "#a5a0b6",
        bright_blue = "#b59790",
        bright_magenta = "#c4d8e2",

        accent = "#b59790",
        cursor = "#e2dddc",
        foreground = "#FAFCFB",
        background = "#0c0b0c",
        selection = "#584e51",
        selection_foreground = "#e2dddc",
        selection_background = "#584e51",
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
