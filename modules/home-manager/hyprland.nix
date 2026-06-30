inputs: {
  config,
  pkgs,
  lib,
  osConfig ? {},
  ...
}: let
  cfg = config.omarchy;
  palette = config.colorScheme.palette;

  hasNvidiaDrivers =
    (osConfig ? services)
    && builtins.elem "nvidia" (osConfig.services.xserver.videoDrivers or []);

  # $terminal/$browser/... Hyprland variables don't exist in the Lua config, so
  # resolve them to concrete commands at build time before emitting o.bind().
  launchOrFocus = "~/.local/share/omarchy/bin/omarchy-launch-or-focus";
  browserCmd =
    if cfg.browser == "brave"
    then "${launchOrFocus} brave 'brave --new-window --ozone-platform=wayland'"
    else "${launchOrFocus} chromium 'chromium --new-window --ozone-platform=wayland'";
  varSubst =
    lib.replaceStrings
    ["$terminal" "$fileManager" "$browser" "$music" "$passwordManager" "$messenger" "$webapp"]
    [
      cfg.terminal
      "${launchOrFocus} nautilus 'nautilus --new-window'"
      browserCmd
      "${launchOrFocus} spotify spotify"
      "${launchOrFocus} 1password 1password"
      "${launchOrFocus} signal 'signal-desktop'"
      "${browserCmd} --app"
    ];

  # Translate one "MODS, KEY, Desc, exec, cmd…" hyprlang bind into an o.bind()
  # Lua call (the framework's `o` DSL is global by the time this file loads).
  mkBind = s: let
    parts = map lib.strings.trim (lib.splitString "," s);
    mods = lib.replaceStrings [" "] [" + "] (builtins.elemAt parts 0);
    key = builtins.elemAt parts 1;
    desc = builtins.elemAt parts 2;
    combo =
      if key == ""
      then mods
      else "${mods} + ${key}";
    # parts[3] is the dispatcher (exec for app launchers); rejoin the rest as cmd
    cmd = varSubst (lib.strings.trim (lib.concatStringsSep "," (lib.drop 4 parts)));
  in "o.bind(${builtins.toJSON combo}, ${builtins.toJSON desc}, ${builtins.toJSON cmd})";

  bindingsLua = ''
    -- Generated from omarchy.quick_app_bindings. Edit your nix config, not here.
    ${lib.concatMapStringsSep "\n" mkBind cfg.quick_app_bindings}
  '';

  # Theme border colours from the active base16 scheme (keeps omarchy-nix's
  # build-time theming; overrides the framework's default gradient borders).
  looknfeelLua = ''
    -- Generated from the active theme palette.
    hl.config({
      general = {
        ["col.active_border"] = "rgba(${palette.base0D}ff)",
        ["col.inactive_border"] = "rgba(${palette.base09}aa)",
      },
    })
  '';

  envEntries =
    (lib.optionals hasNvidiaDrivers [
      ["NVD_BACKEND" "direct"]
      ["LIBVA_DRIVER_NAME" "nvidia"]
      ["__GLX_VENDOR_LIBRARY_NAME" "nvidia"]
    ])
    ++ [
      ["XCURSOR_SIZE" "24"]
      ["HYPRCURSOR_SIZE" "24"]
      ["XCURSOR_THEME" "Bibata-Modern-Classic"]
      ["HYPRCURSOR_THEME" "Bibata-Modern-Classic"]
      ["GDK_BACKEND" "wayland"]
      ["QT_QPA_PLATFORM" "wayland"]
      ["QT_STYLE_OVERRIDE" "kvantum"]
      ["MOZ_ENABLE_WAYLAND" "1"]
      ["ELECTRON_OZONE_PLATFORM_HINT" "wayland"]
      ["OZONE_PLATFORM" "wayland"]
      ["CHROMIUM_FLAGS" "--enable-features=UseOzonePlatform --ozone-platform=wayland --gtk-version=4"]
      ["XCOMPOSEFILE" "~/.XCompose"]
      ["EDITOR" "nvim"]
      ["GTK_THEME" "Adwaita:dark"]
      ["XDG_CURRENT_DESKTOP" "Hyprland"]
      ["XDG_SESSION_TYPE" "wayland"]
      ["XDG_SESSION_DESKTOP" "Hyprland"]
    ];
  envsLua = ''
    -- Generated from the nix Hyprland env set.
    ${lib.concatMapStringsSep "\n" (e: "hl.env(${builtins.toJSON (builtins.elemAt e 0)}, ${builtins.toJSON (builtins.elemAt e 1)})") envEntries}
    hl.config({ xwayland = { force_zero_scaling = true }, ecosystem = { no_update_news = true } })
  '';

  inputLua = ''
    -- Generated from the nix input options.
    hl.config({
      input = {
        kb_layout = "us",
        kb_options = "compose:caps",
        repeat_rate = 40,
        repeat_delay = 250,
        numlock_by_default = true,
        follow_mouse = 1,
        sensitivity = 0,
        touchpad = {
          natural_scroll = false,
          clickfinger_behavior = true,
          scroll_factor = 0.4,
        },
      },
    })
    o.window("(Alacritty|kitty|foot)", { scroll_touchpad = 1.5 })
    o.window("com.mitchellh.ghostty", { scroll_touchpad = 0.2 })
  '';

  monitorsLua = ''
    -- Generated. GDK_SCALE from omarchy.scale; custom monitors go here in Lua:
    -- hl.monitor({ output = "DP-2", mode = "preferred", position = "auto", scale = 1 })
    hl.env("GDK_SCALE", "${toString cfg.scale}")
    hl.monitor({ output = "", mode = "preferred", position = "auto", scale = "auto" })
  '';

  autostartLua = ''
    -- Extra autostart on top of the Omarchy defaults (quickshell, fcitx5,
    -- udiskie, power profiles, monitor-watch all live in default.hypr.autostart).
    o.launch_on_start("wl-clip-persist --clipboard regular")
    o.launch_on_start("clipse -listen")
  '';

  # Entry point Hyprland loads (~/.config/hypr/hyprland.lua). Mirrors upstream's
  # skel loader, with an extra require for our generated envs override.
  hyprlandLua = ''
    -- Drop cached omarchy modules so hyprctl reload re-reads them from disk.
    for k in pairs(package.loaded) do
      if k:match("^default%.hypr") or k:match("^hypr%.") then
        package.loaded[k] = nil
      end
    end

    package.path = os.getenv("HOME")
      .. "/.config/?.lua;"
      .. (os.getenv("OMARCHY_PATH") or "/usr/share/omarchy")
      .. "/?.lua;"
      .. package.path

    require("default.hypr.omarchy")

    require("hypr.monitors")
    require("hypr.input")
    require("hypr.envs")
    require("hypr.bindings")
    require("hypr.looknfeel")
    require("hypr.autostart")

    require("default.hypr.toggles")
  '';
in {
  wayland.windowManager.hyprland = {
    enable = true;
    package = inputs.hyprland.packages.${pkgs.stdenv.hostPlatform.system}.hyprland;
    # We ship a Lua config (Hyprland 0.55 auto-loads ~/.config/hypr/hyprland.lua);
    # leave HM's settings/extraConfig empty so it writes no hyprland.conf.
  };
  # No hyprpolkitagent: omarchy-shell owns the polkit agent (polkit plugin).

  # State dir for the active theme (was created by the now-removed swaybg.nix).
  home.file.".config/omarchy/current/.keep".text = "";

  # The Omarchy 4 Lua config: upstream framework (deployed to
  # $OMARCHY_PATH/default/hypr via default.nix) + nix-generated user overrides.
  xdg.configFile = {
    "hypr/hyprland.lua".text = hyprlandLua;
    "hypr/bindings.lua".text = bindingsLua;
    "hypr/looknfeel.lua".text = looknfeelLua;
    "hypr/envs.lua".text = envsLua;
    "hypr/input.lua".text = inputLua;
    "hypr/monitors.lua".text = monitorsLua;
    "hypr/autostart.lua".text = autostartLua;
  };
}
