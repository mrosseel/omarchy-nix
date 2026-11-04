# Custom base16 color schemes for Omarchy themes
# These themes don't exist in nix-colors, so we define them here
{
  ethereal = {
    slug = "ethereal";
    scheme = "Ethereal";
    author = "Omarchy (port by omarchy-nix)";
    base00 = "060B1E"; # Default Background (dark blue)
    base01 = "0a1028"; # Lighter Background
    base02 = "6d7db6"; # Selection Background
    base03 = "6d7db6"; # Comments, Invisibles
    base04 = "a3bfd1"; # Dark Foreground
    base05 = "ffcead"; # Default Foreground (peachy)
    base06 = "ffd9c0"; # Light Foreground
    base07 = "fff0e8"; # Light Background
    base08 = "fd6883"; # Variables (red/pink)
    base09 = "f38d70"; # Integers (orange)
    base0A = "c89dc1"; # Classes (pink)
    base0B = "92a593"; # Strings (green)
    base0C = "7cf8f7"; # Regex (cyan)
    base0D = "4E85D8"; # Functions (blue - active border)
    base0E = "7d82d9"; # Keywords (purple)
    base0F = "c89dc1"; # Deprecated (pink)
  };

  hackerman = {
    slug = "hackerman";
    scheme = "Hackerman";
    author = "Omarchy (port by omarchy-nix)";
    base00 = "0B0C16"; # Default Background (very dark blue)
    base01 = "15161f"; # Lighter Background
    base02 = "6a6e95"; # Selection Background
    base03 = "6a6e95"; # Comments, Invisibles
    base04 = "7cf8f7"; # Dark Foreground (cyan)
    base05 = "ddf7ff"; # Default Foreground (bright cyan-white)
    base06 = "eafbff"; # Light Foreground
    base07 = "ffffff"; # Light Background
    base08 = "fd6883"; # Variables (red/pink)
    base09 = "f38d70"; # Integers (orange)
    base0A = "86a7df"; # Classes (blue)
    base0B = "4fe88f"; # Strings (bright green - main accent)
    base0C = "7cf8f7"; # Regex (cyan)
    base0D = "26a269"; # Functions (green - active border)
    base0E = "829dd4"; # Keywords (purple/blue)
    base0F = "2ec27e"; # Deprecated (green)
  };

  # Derived from upstream themes/jade-horse/colors.toml (dark, jade green).
  # Jade Horse replaced Osaka Jade upstream (#16594).
  jade-horse = {
    slug = "jade-horse";
    scheme = "Jade Horse";
    author = "Omarchy (port by omarchy-nix)";
    base00 = "142620"; # Default Background
    base01 = "0f1e19"; # Lighter Background (dark_background)
    base02 = "2b5147"; # Selection Background
    base03 = "64887b"; # Comments, Invisibles (muted)
    base04 = "91ad9f"; # Dark Foreground
    base05 = "dfede5"; # Default Foreground
    base06 = "bed6c9"; # Light Foreground
    base07 = "f0faf4"; # Light Background (bright_foreground)
    base08 = "d88d91"; # Variables (red)
    base09 = "d2ab8d"; # Integers (orange)
    base0A = "c5cc91"; # Classes (yellow)
    base0B = "8bcbb1"; # Strings (green)
    base0C = "86c7c5"; # Regex (cyan)
    base0D = "8bcbb1"; # Functions (accent, active border)
    base0E = "b7a1c8"; # Keywords (magenta)
    base0F = "7e8970"; # Deprecated (brown)
  };

  ristretto = {
    slug = "ristretto";
    scheme = "Ristretto";
    author = "Omarchy (port by omarchy-nix)";
    base00 = "2c2421"; # Default Background (dark brown)
    base01 = "3d2f2a"; # Lighter Background
    base02 = "3d2f2a"; # Selection Background
    base03 = "72696a"; # Comments, Invisibles
    base04 = "72696a"; # Dark Foreground
    base05 = "e6d9db"; # Default Foreground (cream/pink)
    base06 = "f0e7e9"; # Light Foreground
    base07 = "faf5f7"; # Light Background
    base08 = "fd6883"; # Variables (pink/red)
    base09 = "f38d70"; # Integers (orange)
    base0A = "adda78"; # Classes (lime green)
    base0B = "adda78"; # Strings (green)
    base0C = "a8a9eb"; # Regex (lavender)
    base0D = "a8a9eb"; # Functions (purple/blue)
    base0E = "fd6a85"; # Keywords (pink)
    base0F = "5b4a45"; # Deprecated (brown)
  };

  miasma = {
    slug = "miasma";
    scheme = "Miasma";
    author = "Omarchy (port by omarchy-nix)";
    base00 = "222222"; # Default Background
    base01 = "2a2a2a"; # Lighter Background
    base02 = "78824b"; # Selection Background (accent)
    base03 = "666666"; # Comments, Invisibles
    base04 = "c2c2b0"; # Dark Foreground
    base05 = "c2c2b0"; # Default Foreground
    base06 = "d7c483"; # Light Foreground
    base07 = "d7c483"; # Light Background
    base08 = "685742"; # Variables (brown)
    base09 = "b36d43"; # Integers (orange)
    base0A = "c9a554"; # Classes (gold)
    base0B = "5f875f"; # Strings (green)
    base0C = "c9a554"; # Regex (gold)
    base0D = "78824b"; # Functions (olive - active border)
    base0E = "bb7744"; # Keywords (orange-brown)
    base0F = "685742"; # Deprecated (brown)
  };

  vantablack = {
    slug = "vantablack";
    scheme = "Vantablack";
    author = "Omarchy (port by omarchy-nix)";
    base00 = "000000"; # Default Background (true black)
    base01 = "1a1a1a"; # Lighter Background
    base02 = "ffffff"; # Selection Background
    base03 = "5c5c5c"; # Comments, Invisibles (color8 grey)
    base04 = "ececec"; # Dark Foreground
    base05 = "ffffff"; # Default Foreground
    base06 = "ffffff"; # Light Foreground
    base07 = "ffffff"; # Light Background
    base08 = "a4a4a4"; # Variables
    base09 = "cecece"; # Integers
    base0A = "b0b0b0"; # Classes
    base0B = "b6b6b6"; # Strings
    base0C = "b0b0b0"; # Regex
    base0D = "8d8d8d"; # Functions (accent - active border)
    base0E = "9b9b9b"; # Keywords
    base0F = "a4a4a4"; # Deprecated
  };

  white = {
    slug = "white";
    scheme = "White";
    author = "Omarchy (port by omarchy-nix)";
    base00 = "ffffff"; # Default Background
    base01 = "f0f0f0"; # Lighter Background
    base02 = "1a1a1a"; # Selection Background
    base03 = "c0c0c0"; # Comments, Invisibles
    base04 = "000000"; # Dark Foreground
    base05 = "000000"; # Default Foreground
    base06 = "000000"; # Light Foreground
    base07 = "000000"; # Light Background
    base08 = "2a2a2a"; # Variables
    base09 = "4a4a4a"; # Integers
    base0A = "3e3e3e"; # Classes
    base0B = "3a3a3a"; # Strings
    base0C = "3e3e3e"; # Regex
    base0D = "1a1a1a"; # Functions (active border)
    base0E = "2e2e2e"; # Keywords
    base0F = "6e6e6e"; # Deprecated (accent)
  };

  retro-82 = {
    slug = "retro-82";
    scheme = "Retro '82";
    author = "Omarchy (port by omarchy-nix)";
    base00 = "05182e"; # Default Background (deep navy)
    base01 = "00172e"; # Lighter Background
    base02 = "134e5a"; # Selection Background
    base03 = "134e5a"; # Comments, Invisibles
    base04 = "a7c9c6"; # Dark Foreground
    base05 = "f6dcac"; # Default Foreground (warm cream)
    base06 = "f6dcac"; # Light Foreground
    base07 = "f6dcac"; # Light Background
    base08 = "f85525"; # Variables (red/orange)
    base09 = "e97b3c"; # Integers (orange)
    base0A = "faa968"; # Classes (amber accent)
    base0B = "028391"; # Strings (teal)
    base0C = "8cbfb8"; # Regex (cyan)
    base0D = "faa968"; # Functions (amber - active border)
    base0E = "3f8f8a"; # Keywords (dark teal)
    base0F = "f85525"; # Deprecated (red)
  };

  lumon = {
    slug = "lumon";
    scheme = "Lumon";
    author = "Omarchy (port by omarchy-nix)";
    base00 = "16242d"; # Default Background (dark blue-green)
    base01 = "1b2d40"; # Lighter Background
    base02 = "304860"; # Selection Background
    base03 = "304860"; # Comments, Invisibles
    base04 = "d6e2ee"; # Dark Foreground
    base05 = "d6e2ee"; # Default Foreground (light blue-grey)
    base06 = "f2fcff"; # Light Foreground
    base07 = "ffffff"; # Light Background
    base08 = "4d86b0"; # Variables (blue)
    base09 = "6fa4c9"; # Integers (light blue)
    base0A = "6fb8e3"; # Classes (sky blue)
    base0B = "5e95bc"; # Strings (steel blue)
    base0C = "b4e4f6"; # Regex (pale blue)
    base0D = "8bc9eb"; # Functions (light sky - new accent / active border)
    base0E = "8bc9eb"; # Keywords (light sky)
    base0F = "4d86b0"; # Deprecated (blue)
  };

  # Derived from upstream themes/lupine/colors.toml (a light theme).
  lupine = {
    slug = "lupine";
    scheme = "Lupine";
    author = "Omarchy (port by omarchy-nix)";
    base00 = "fafafa"; # Default Background
    base01 = "ececec"; # Lighter Background (dark_background)
    base02 = "d0d0d0"; # Selection Background
    base03 = "9e9e9e"; # Comments, Invisibles (muted)
    base04 = "757575"; # Dark Foreground
    base05 = "212121"; # Default Foreground
    base06 = "424242"; # Light Foreground
    base07 = "000000"; # Light Background (bright_foreground)
    base08 = "c900c4"; # Variables (red)
    base09 = "026fde"; # Integers (orange)
    base0A = "026fde"; # Classes (yellow)
    base0B = "4a2fd0"; # Strings (green)
    base0C = "0c67de"; # Regex (cyan)
    base0D = "3264eb"; # Functions (blue / accent)
    base0E = "8a4ad7"; # Keywords (magenta)
    base0F = "013a6f"; # Deprecated (brown)
  };

  # Derived from upstream themes/solitude/colors.toml (dark, near-monochrome).
  solitude = {
    slug = "solitude";
    scheme = "Solitude";
    author = "Omarchy (port by omarchy-nix)";
    base00 = "101315"; # Default Background
    base01 = "0c0e10"; # Lighter Background (dark_background)
    base02 = "343d41"; # Selection Background
    base03 = "4b4e55"; # Comments, Invisibles (muted)
    base04 = "4b4e55"; # Dark Foreground
    base05 = "cacccc"; # Default Foreground
    base06 = "cbc2be"; # Light Foreground
    base07 = "a5aeb4"; # Light Background (bright_foreground)
    base08 = "565d60"; # Variables (red)
    base09 = "de6145"; # Integers (bright_red — the one warm accent)
    base0A = "d9dbdc"; # Classes (yellow)
    base0B = "9fa5a9"; # Strings (green)
    base0C = "707070"; # Regex (cyan)
    base0D = "798186"; # Functions (blue / accent — active border)
    base0E = "aeaeae"; # Keywords (magenta)
    base0F = "5d6367"; # Deprecated (bright_blue)
  };

  # Derived from upstream themes/last-horizon/colors.toml (dark, warm/dusty).
  last-horizon = {
    slug = "last-horizon";
    scheme = "Last Horizon";
    author = "Omarchy (port by omarchy-nix)";
    base00 = "0c0b0c"; # Default Background
    base01 = "090809"; # Lighter Background (dark_background)
    base02 = "584e51"; # Selection Background
    base03 = "584e51"; # Comments, Invisibles (muted)
    base04 = "584e51"; # Dark Foreground
    base05 = "fafcfb"; # Default Foreground
    base06 = "cfd3cd"; # Light Foreground
    base07 = "e2dddc"; # Light Background (bright_foreground)
    base08 = "c38b7b"; # Variables (red)
    base09 = "c38b7b"; # Integers (orange)
    base0A = "6b5e73"; # Classes (yellow)
    base0B = "87a9b0"; # Strings (green)
    base0C = "a5a0b6"; # Regex (cyan)
    base0D = "b59790"; # Functions (blue / accent — active border)
    base0E = "c4d8e2"; # Keywords (magenta)
    base0F = "8a8588"; # Deprecated (border mid-tone)
  };

  # Derived from upstream themes/starship/colors.toml (dark, warm orange accent).
  starship = {
    slug = "starship";
    scheme = "Starship";
    author = "Omarchy (port by omarchy-nix)";
    base00 = "1c1c1e"; # Default Background
    base01 = "161618"; # Lighter Background (dark_background)
    base02 = "3a3a3c"; # Selection Background
    base03 = "8e8e93"; # Comments, Invisibles (muted)
    base04 = "98989d"; # Dark Foreground
    base05 = "f5f5f7"; # Default Foreground
    base06 = "fbfbfd"; # Light Foreground
    base07 = "ffffff"; # Light Background (bright_foreground)
    base08 = "ff5f4a"; # Variables (red)
    base09 = "ff6a3d"; # Integers (orange)
    base0A = "ffc27a"; # Classes (yellow)
    base0B = "ff9f0a"; # Strings (green; upstream sets it to the accent orange)
    base0C = "a6dcef"; # Regex (cyan)
    base0D = "ff9f0a"; # Functions (accent, active border)
    base0E = "ff8fa3"; # Keywords (magenta)
    base0F = "b8a99a"; # Deprecated (brown)
  };
}
