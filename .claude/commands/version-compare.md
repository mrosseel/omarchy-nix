# Package Version Comparison: Omarchy vs Omarchy-nix

Compare package versions between original Omarchy (Arch Linux) and Omarchy-nix to identify gaps.

## Instructions

Generate a version comparison table by querying these sources:

### 1. Omarchy Stable Mirror (Arch packages)

```bash
curl -s "https://stable-mirror.omarchy.org/extra/os/x86_64/extra.db.tar.gz" | \
  tar -tzf - 2>/dev/null | grep -E "^(hyprland|waybar|mako|ghostty|hypridle|hyprlock|swayosd|kitty|alacritty)-[0-9]"
```

Parse version from output like `hyprland-0.53.1-1/` → `0.53.1`

### 2. Arch Linux Current (for edge comparison)

```bash
for pkg in hyprland waybar mako ghostty hypridle hyprlock swayosd kitty alacritty; do
  ver=$(curl -s "https://archlinux.org/packages/extra/x86_64/$pkg/json/" 2>/dev/null | jq -r '.pkgver // "-"')
  echo "$pkg: $ver"
done
```

### 3. OPR Edge (custom omarchy packages like walker)

```bash
# Get walker version from OPR
curl -sL "https://api.github.com/repos/omacom-io/omarchy-pkgs/contents/pkgbuilds/edge/walker/PKGBUILD" | \
  jq -r '.content' | base64 -d | grep "^pkgver="
```

### 4. Nixpkgs Unstable

```bash
for pkg in hyprland waybar mako ghostty hypridle hyprlock swayosd kitty alacritty; do
  ver=$(nix eval nixpkgs#$pkg.version --raw 2>/dev/null || echo "-")
  echo "$pkg: $ver"
done
```

### 5. Omarchy-nix Pinned Versions

Check `flake.nix` for pinned versions:
```bash
grep -E "url.*v[0-9]" /home/mike/dev/omacom/omarchy-nix/flake.nix
```

Current known pins:
- Hyprland: Check `hyprland.url` in flake.nix
- Walker: Check `walker.url` in flake.nix

### 6. Currently Installed (optional)

```bash
hyprctl version 2>/dev/null | grep -oP "Hyprland \K[0-9.]+"
walker --version 2>/dev/null
ghostty --version 2>/dev/null | head -1
```

## Output Format

Generate this table:

```
| Package | Omarchy Stable | Arch Edge | OPR Edge | Omarchy-nix | nixpkgs | Gap? |
|---------|---------------|-----------|----------|-------------|---------|------|
| hyprland | X.X.X | X.X.X | - | X.X.X (pinned) | X.X.X | [YES/NO] |
| walker | - | - | X.X.X | X.X.X (pinned) | - | [YES/NO] |
| waybar | X.X.X | X.X.X | - | X.X.X | X.X.X | [YES/NO] |
...
```

Mark "Gap? = YES" if omarchy-nix version differs from OPR/Arch versions.

## Key Packages to Compare

**Core Hyprland stack:**
- hyprland, hypridle, hyprlock, hyprpicker, hyprsunset

**Terminals:**
- ghostty, kitty, alacritty

**UI Components:**
- waybar, mako, swayosd, walker

**OPR Custom (check github.com/omacom-io/omarchy-pkgs):**
- walker, elephant, omarchy-walker (meta-package)

## Walker + Elephant Special Case

Walker in omarchy uses the OPR-built version with elephant providers.

Check OPR walker version:
```bash
curl -sL "https://api.github.com/repos/omacom-io/omarchy-pkgs/contents/pkgbuilds/edge/walker/PKGBUILD" | \
  jq -r '.content' | base64 -d | grep "^pkgver="
```

Omarchy-nix pins walker in flake.nix and builds elephant from source.

## After Comparison

If gaps are found, suggest updates to `flake.nix`:
```nix
# Example: updating walker pin
walker.url = "github:abenz1267/walker/vX.X.X";
```

$ARGUMENTS
