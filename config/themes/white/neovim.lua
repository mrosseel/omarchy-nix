return {
  {
    "omacom/aether.nvim",
    branch = "v3",
    name = "aether",
    priority = 1000,
    opts = {
      colors = {
        bg = "#ffffff",
        dark_bg = "#f5f5f5",
        darker_bg = "#e8e8e8",
        lighter_bg = "#c0c0c0",

        fg = "#000000",
        dark_fg = "#c0c0c0",
        light_fg = "#000000",
        bright_fg = "#000000",
        muted = "#808080",

        red = "#2a2a2a",
        yellow = "#4a4a4a",
        orange = "#4a4a4a",
        green = "#3a3a3a",
        cyan = "#3e3e3e",
        blue = "#1a1a1a",
        magenta = "#2e2e2e",
        brown = "#252525",

        bright_red = "#2a2a2a",
        bright_yellow = "#4a4a4a",
        bright_green = "#3a3a3a",
        bright_cyan = "#3e3e3e",
        bright_blue = "#1a1a1a",
        bright_magenta = "#2e2e2e",

        accent = "#6e6e6e",
        cursor = "#000000",
        foreground = "#000000",
        background = "#ffffff",
        selection = "#c0c0c0",
        selection_foreground = "#000000",
        selection_background = "#c0c0c0",
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
