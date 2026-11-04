return {
  {
    "omacom/aether.nvim",
    branch = "v3",
    name = "aether",
    priority = 1000,
    opts = {
      colors = {
        bg = "#2c2525",
        dark_bg = "#211b1b",
        darker_bg = "#181414",
        lighter_bg = "#3d2f2a",

        fg = "#e6d9db",
        dark_fg = "#72696a",
        light_fg = "#c3b7b8",
        bright_fg = "#e6d9db",
        muted = "#72696a",

        red = "#fd6883",
        yellow = "#f9cc6c",
        orange = "#fb9a77",
        green = "#adda78",
        cyan = "#85dacc",
        blue = "#f38d70",
        magenta = "#a8a9eb",
        brown = "#7d4d3b",

        bright_red = "#ff8297",
        bright_yellow = "#fcd675",
        bright_green = "#c8e292",
        bright_cyan = "#9bf1e1",
        bright_blue = "#f8a788",
        bright_magenta = "#bebffd",

        accent = "#f38d70",
        cursor = "#e6d9db",
        foreground = "#e6d9db",
        background = "#2c2525",
        selection = "#403e41",
        selection_foreground = "#e6d9db",
        selection_background = "#403e41",
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
