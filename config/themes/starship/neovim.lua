return {
  {
    "omacom/aether.nvim",
    branch = "v3",
    name = "aether",
    priority = 1000,
    opts = {
      colors = {
        bg = "#1c1c1e",
        dark_bg = "#161618",
        darker_bg = "#0e0e10",
        lighter_bg = "#2c2c2e",

        fg = "#f5f5f7",
        dark_fg = "#98989d",
        light_fg = "#fbfbfd",
        bright_fg = "#ffffff",
        muted = "#8e8e93",

        red = "#ff5f4a",
        yellow = "#ffc27a",
        orange = "#ff6a3d",
        green = "#ff9f0a",
        cyan = "#a6dcef",
        blue = "#8fb8de",
        magenta = "#ff8fa3",
        brown = "#b8a99a",

        bright_red = "#ff8373",
        bright_yellow = "#ffd8a8",
        bright_green = "#ffb340",
        bright_cyan = "#cdeefa",
        bright_blue = "#b5d0ea",
        bright_magenta = "#ffb3c1",

        accent = "#ff9f0a",
        cursor = "#ffffff",
        foreground = "#f5f5f7",
        background = "#1c1c1e",
        selection = "#3a3a3c",
        selection_foreground = "#ffffff",
        selection_background = "#3a3a3c",
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
