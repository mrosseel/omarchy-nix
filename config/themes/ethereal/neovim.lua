return {
  {
    "omacom/aether.nvim",
    branch = "v3",
    name = "aether",
    priority = 1000,
    opts = {
      colors = {
        bg = "#060B1E",
        dark_bg = "#040816",
        darker_bg = "#030610",
        lighter_bg = "#131a3a",

        fg = "#ffcead",
        dark_fg = "#6d7db6",
        light_fg = "#c9b8a6",
        bright_fg = "#ffcead",
        muted = "#6d7db6",

        red = "#ED5B5A",
        yellow = "#E9BB4F",
        orange = "#eb8b54",
        green = "#92a593",
        cyan = "#a3bfd1",
        blue = "#7d82d9",
        magenta = "#c89dc1",
        brown = "#75452a",

        bright_red = "#faaaa9",
        bright_yellow = "#f7dc9c",
        bright_green = "#c4cfc4",
        bright_cyan = "#dfeaf0",
        bright_blue = "#c2c4f0",
        bright_magenta = "#ead7e7",

        accent = "#7d82d9",
        cursor = "#ffcead",
        foreground = "#ffcead",
        background = "#060B1E",
        selection = "#252e56",
        selection_foreground = "#ffcead",
        selection_background = "#252e56",
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
