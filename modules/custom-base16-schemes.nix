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

  osaka-jade = {
    slug = "osaka-jade";
    scheme = "Osaka Jade";
    author = "Omarchy (port by omarchy-nix)";
    base00 = "11221C"; # Default Background (dark green-black)
    base01 = "192b24"; # Lighter Background
    base02 = "364538"; # Selection Background
    base03 = "32473B"; # Comments, Invisibles
    base04 = "C1C497"; # Dark Foreground (beige)
    base05 = "e6d8ba"; # Default Foreground (cream)
    base06 = "f0e8cc"; # Light Foreground
    base07 = "faf5e8"; # Light Background
    base08 = "E67D64"; # Variables (coral/red)
    base09 = "DEB266"; # Integers (orange/gold)
    base0A = "E1B55E"; # Classes (yellow)
    base0B = "81B8A8"; # Strings (teal)
    base0C = "71CEAD"; # Regex (jade - active border)
    base0D = "71CEAD"; # Functions (jade)
    base0E = "D6D5BC"; # Keywords (beige)
    base0F = "BFD99A"; # Deprecated (lime green)
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
}
