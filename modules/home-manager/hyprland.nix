inputs: {
  config,
  pkgs,
  lib,
  ...
}: let
  cfg = config.omarchy;

  hyprlandPkg = inputs.hyprland.packages.${pkgs.stdenv.hostPlatform.system}.hyprland;

  # Titlebars for floating workspaces. A Hyprland plugin loads only into the
  # Hyprland it was built against, so build it against the session's Hyprland.
  titlebars = pkgs.callPackage ../../packages/omarchy-hyprland-titlebars.nix {
    hyprland = hyprlandPkg;
  };

  # The vendored Omarchy Lua framework, deployed to $OMARCHY_PATH/default/hypr.
  # Upstream loads the titlebars plugin from its Arch path. That path does not
  # exist on Nix, so point it at the store path at build time. The vendored
  # file stays a plain copy of upstream.
  defaultHypr = pkgs.runCommand "omarchy-default-hypr" {} ''
    cp -r --no-preserve=mode ${../../default/hypr} $out
    substituteInPlace $out/workspace-modes.lua \
      --replace-fail /usr/lib/omarchy-hyprland-titlebars/titlebars.so ${titlebars.pluginPath}
  '';

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

  # The NVIDIA variables are not set here. Upstream default/hypr/nvidia.lua
  # sets them from the hardware, and sets the VA-API and GLX drivers only when
  # NVIDIA drives the display. A value here would override that check.
  envEntries = [
    ["XCURSOR_SIZE" "24"]
    ["HYPRCURSOR_SIZE" "24"]
    ["XCURSOR_THEME" "Bibata-Modern-Classic"]
    ["HYPRCURSOR_THEME" "Bibata-Modern-Classic"]
    ["GDK_BACKEND" "wayland"]
    ["QT_QPA_PLATFORM" "wayland"]
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

  # Upstream skel (config/hypr/input.lua): comments only. Omarchy's input
  # defaults live in default/hypr/input.lua, which reads the keyboard layout and
  # sets kb_options from /etc/xkb (modules/nixos/hyprland.nix). Settings here
  # would replace those defaults.
  inputLua = builtins.readFile ../../config/hypr/input.lua;

  # Upstream skel (config/hypr/monitors.lua). Seeded once as a user-owned file
  # (the monitor panel and Setup > Monitors edit it). Omarchy's defaults live in
  # default/hypr/monitors.lua, which sets GDK_SCALE to 2. Nix deviation: an
  # omarchy.scale other than 2 is added as a GDK_SCALE line. Later changes to
  # omarchy.scale only affect a fresh seed, like upstream.
  monitorsLua =
    builtins.readFile ../../config/hypr/monitors.lua
    + lib.optionalString (cfg.scale != 2) ''

      -- Set from omarchy.scale.
      hl.env("GDK_SCALE", "${toString cfg.scale}")
    '';

  autostartLua = ''
    -- Extra autostart on top of the Omarchy defaults (quickshell, fcitx5,
    -- udiskie, power profiles, monitor-watch all live in default.hypr.autostart).
    -- Clipboard is owned by omarchy-shell (shell/plugins/clipboard) as of v4;
    -- upstream dropped the old wl-clip-persist + clipse autostart. The port's
    -- omarchy-shell clipboard watcher works once the shell runs current QML,
    -- which omarchy-shell.nix now guarantees by restarting the shell on switch.
  '';

  ##########################################################################
  # HM → Lua bridge. Hyprland 0.55 loads ONLY hyprland.lua when present, so a
  # user's personal `wayland.windowManager.hyprland.settings`/`extraConfig`
  # (which HM writes to the now-ignored hyprland.conf) would be lost. We read
  # those merged values here and translate them into Lua, required AFTER the
  # Omarchy defaults so the user's overrides win. No nixos-config changes.
  ##########################################################################
  hmHypr = config.wayland.windowManager.hyprland;
  userSettings = hmHypr.settings or {};
  userExtra = hmHypr.extraConfig or "";

  toLua = v:
    if builtins.isBool v
    then
      (
        if v
        then "true"
        else "false"
      )
    else if builtins.isInt v
    then toString v
    else if builtins.isFloat v
    then toString v
    else if builtins.isString v
    then builtins.toJSON v
    else if builtins.isList v
    then "{" + lib.concatMapStringsSep ", " toLua v + "}"
    else if builtins.isAttrs v
    then "{ " + lib.concatStringsSep ", " (lib.mapAttrsToList (k: val: "[${builtins.toJSON k}] = ${toLua val}") v) + " }"
    else "nil";

  asList = v:
    if builtins.isList v
    then v
    else [v];
  isBindKey = k: lib.hasPrefix "bind" k;
  specialNonBind = ["exec" "exec-once" "execr" "exec-shutdown" "monitor" "env" "windowrule" "windowrulev2" "layerrule" "layerrulev2" "source"];
  isSpecialKey = k: isBindKey k || lib.elem k specialNonBind || lib.hasPrefix "$" k;
  regularSettings = lib.filterAttrs (k: _: !(isSpecialKey k)) userSettings;

  # The v4 lua API namespaced or renamed most of the classic hyprlang
  # dispatchers. `hl.dsp.workspace` is a *table* (toggle_special, move, rename,
  # change_id, swap_monitors), not a function, and `movetoworkspace` /
  # `movetoworkspacesilent` do not exist under any name — so the generic
  # `hl.dsp.<dispatcher>(args)` form below emits lua that throws the moment
  # Hyprland loads the config, and the bind is silently dead. Identical in 0.55
  # and 0.56, so this is not a version skew.
  #
  # Each entry takes the already-JSON-quoted argument string (or null when the
  # bind carried none) and returns the call upstream writes for that action in
  # default/hypr/bindings/*.lua. Only dispatchers whose lua form is demonstrated
  # there are listed; anything absent keeps the generic form, which is correct
  # for every dispatcher the API left callable at the top level (focus, layout,
  # exec_cmd, dpms, submap, global, pass, …).
  luaDispatchers = {
    workspace = arg: "hl.dsp.focus({ workspace = ${arg} })";
    movetoworkspace = arg: "hl.dsp.window.move({ workspace = ${arg} })";
    movetoworkspacesilent = arg: "hl.dsp.window.move({ workspace = ${arg}, follow = false })";
    movefocus = arg: "hl.dsp.focus({ direction = ${arg} })";
    focusmonitor = arg: "hl.dsp.focus({ monitor = ${arg} })";
    movecurrentworkspacetomonitor = arg: "hl.dsp.workspace.move({ monitor = ${arg} })";
    togglespecialworkspace = arg: "hl.dsp.workspace.toggle_special(${arg})";
    killactive = _: "hl.dsp.window.close()";
    togglefloating = _: "hl.dsp.window.float({ action = \"toggle\" })";
    pseudo = _: "hl.dsp.window.pseudo()";
    bringactivetotop = _: "hl.dsp.window.bring_to_top()";
    togglesplit = _: "hl.dsp.layout(\"togglesplit\")";
  };

  # Translate a hyprlang bind value ("MODS, KEY[, desc], dispatcher, args…")
  # for directive `bindX`, where the X letters are flags (d=description,
  # e=repeat, l=locked, r=release, m=mouse). exec dispatchers become o.bind
  # exec-commands; other dispatchers are passed through as a raw dispatcher.
  mkBindFrom = directive: s: let
    flags = lib.removePrefix "bind" directive;
    hasDesc = lib.hasInfix "d" flags;
    optList =
      lib.optional (lib.hasInfix "r" flags) "release = true"
      ++ lib.optional (lib.hasInfix "e" flags) "repeating = true"
      ++ lib.optional (lib.hasInfix "l" flags) "locked = true"
      ++ lib.optional (lib.hasInfix "m" flags) "mouse = true";
    optStr =
      if optList == []
      then ""
      else ", { ${lib.concatStringsSep ", " optList} }";
    parts = map lib.strings.trim (lib.splitString "," s);
    mods = lib.replaceStrings [" "] [" + "] (builtins.elemAt parts 0);
    key = builtins.elemAt parts 1;
    combo =
      if mods == ""
      then key
      else if key == ""
      then mods
      else "${mods} + ${key}";
    dispIdx =
      if hasDesc
      then 3
      else 2;
    descArg =
      if hasDesc
      then builtins.toJSON (builtins.elemAt parts 2)
      else "nil";
    dispatcher = builtins.elemAt parts dispIdx;
    rest = lib.strings.trim (lib.concatStringsSep "," (lib.drop (dispIdx + 1) parts));
    argStr =
      if rest == ""
      then ""
      else builtins.toJSON rest;
    dispatcherCall =
      if luaDispatchers ? ${dispatcher}
      then luaDispatchers.${dispatcher} argStr
      else "hl.dsp.${dispatcher}(${argStr})";
  in
    if dispatcher == "exec"
    then "o.bind(${builtins.toJSON combo}, ${descArg}, ${builtins.toJSON rest}${optStr})"
    # o.bind(keys, description, dispatcher, options) takes a dispatcher value as
    # happily as an exec string, and it is what puts the entry in the keybindings
    # menu. Route described binds through it whatever the dispatcher — going
    # straight to hl.bind would drop the description and hide the binding.
    else if hasDesc
    then "o.bind(${builtins.toJSON combo}, ${descArg}, ${dispatcherCall}${optStr})"
    else "hl.bind(${builtins.toJSON combo}, ${dispatcherCall}${optStr})";

  # settings.bind* / exec-once / env (lists) → lua
  settingsBinds = lib.concatLists (lib.mapAttrsToList (k: v: lib.optionals (isBindKey k) (map (mkBindFrom k) (asList v))) userSettings);
  settingsExec = lib.concatLists (lib.mapAttrsToList (k: v: lib.optionals (k == "exec-once" || k == "exec") (map (s: "o.exec_on_start(${builtins.toJSON s})") (asList v))) userSettings);
  settingsEnv = lib.concatLists (lib.mapAttrsToList (k: v: lib.optionals (k == "env") (map (s: let p = lib.splitString "," s; in "hl.env(${builtins.toJSON (builtins.head p)}, ${builtins.toJSON (lib.concatStringsSep "," (builtins.tail p))})") (asList v))) userSettings);

  # raw extraConfig hyprlang → lua, line by line
  parseExtraLine = line: let
    t = lib.strings.trim line;
    m = builtins.match "([a-z-]+)[[:space:]]*=[[:space:]]*(.*)" t;
  in
    if t == "" || lib.hasPrefix "#" t
    then ""
    else if m == null
    then "-- [hm-untranslated] ${t}"
    else let
      directive = builtins.elemAt m 0;
      rest = builtins.elemAt m 1;
    in
      if isBindKey directive
      then mkBindFrom directive rest
      else if directive == "exec-once" || directive == "exec"
      then "o.exec_on_start(${builtins.toJSON rest})"
      else "-- [hm-untranslated '${directive}'] ${t}";

  hmLua = ''
    -- Generated from your Home-Manager wayland.windowManager.hyprland.settings
    -- and extraConfig, translated to Lua (Hyprland 0.55 loads only hyprland.lua).
    -- Edit your nix config, not this file.
    ${lib.optionalString (regularSettings != {}) "hl.config(${toLua regularSettings})"}
    ${lib.concatStringsSep "\n" settingsBinds}
    ${lib.concatStringsSep "\n" settingsExec}
    ${lib.concatStringsSep "\n" settingsEnv}
    ${lib.concatMapStringsSep "\n" parseExtraLine (lib.splitString "\n" userExtra)}
  '';

  # Entry point Hyprland loads (~/.config/hypr/hyprland.lua). Mirrors upstream's
  # skel loader, with an extra require for our generated envs override.
  hyprlandLua = ''
    -- OMARCHY_PATH is NOT reliably exported into Hyprland's config-parse
    -- environment, so we cannot dofile bootstrap.lua via $OMARCHY_PATH (it would
    -- fall back to /usr/share/omarchy, which does not exist on Nix -> emergency
    -- mode). Inline bootstrap.lua's logic (quattro) with a HOME-based fallback.
    local omarchy = os.getenv("OMARCHY_PATH")
    if not omarchy or omarchy == "" then
      omarchy = os.getenv("HOME") .. "/.local/share/omarchy"
    end

    -- Module search path: generated state, user config, then Omarchy defaults.
    package.path = os.getenv("HOME") .. "/.local/state/?.lua;"
      .. os.getenv("HOME") .. "/.config/?.lua;"
      .. omarchy .. "/?.lua;"
      .. package.path

    -- Drop cached omarchy/theme modules so hyprctl reload re-reads from disk.
    for k in pairs(package.loaded) do
      if k:match("^default%.hypr") or k:match("^hypr%.") or k:match("^omarchy%.current%.theme") then
        package.loaded[k] = nil
      end
    end

    require("default.hypr.omarchy")

    require("hypr.monitors")
    require("hypr.input")
    require("hypr.envs")
    require("hypr.bindings")
    require("hypr.autostart")

    -- Your personal HM config (settings/extraConfig) translated to Lua, loaded
    -- last so it overrides the Omarchy defaults.
    require("hypr.hm")

    require("default.hypr.toggles")
  '';
in {
  wayland.windowManager.hyprland = {
    enable = true;
    package = hyprlandPkg;
    # Keep HM emitting hyprland.conf (hyprlang), not hyprland.lua. HM's default
    # configType flips to "lua" at stateVersion 26.05; if it wrote its own
    # hyprland.lua it would collide with the one we ship via xdg.configFile below.
    # Pinning hyprlang keeps HM's output the harmless (ignored) hyprland.conf.
    configType = "hyprlang";
    # We ship a Lua config; Hyprland 0.55 auto-loads ~/.config/hypr/hyprland.lua
    # and ignores hyprland.conf when the .lua exists. HM may still write a
    # hyprland.conf from any settings/extraConfig — it's harmless (ignored), and
    # we translate those same values into Lua (hmLua) so they take effect.
  };
  # No hyprpolkitagent: omarchy-shell owns the polkit agent (polkit plugin).

  # State dir for the active theme (was created by the now-removed swaybg.nix).
  home.file.".config/omarchy/current/.keep".text = "";

  home.file.".local/share/omarchy/default/hypr" = {
    source = defaultHypr;
    recursive = true;
  };

  # The Omarchy 4 Lua config: upstream framework (deployed to
  # $OMARCHY_PATH/default/hypr above) + nix-generated user overrides.
  xdg.configFile = {
    "hypr/hyprland.lua".text = hyprlandLua;
    "hypr/bindings.lua".text = bindingsLua;
    "hypr/envs.lua".text = envsLua;
    "hypr/input.lua".text = inputLua;
    "hypr/autostart.lua".text = autostartLua;
    "hypr/hm.lua".text = hmLua;
  };

  # monitors.lua is NOT an HM store symlink like the other lua files: omarchy's
  # runtime tools (omarchy-hyprland-monitor-scaling / -clamshell, omarchy-refresh
  # -hyprland) rewrite it as a real file. An immutable symlink fights that — the
  # runtime replaces it, then the next home-manager switch tries to back it up and
  # dies on a stale monitors.lua.backup. Seed the default once and then leave it
  # to the user/runtime, matching upstream omarchy (installs it, then you edit it).
  home.activation.seedMonitorsLua = lib.hm.dag.entryAfter ["writeBoundary"] ''
    monitors="$HOME/.config/hypr/monitors.lua"
    if [ ! -e "$monitors" ]; then
      run mkdir -p "$(dirname "$monitors")"
      run install -m644 ${pkgs.writeText "monitors.lua" monitorsLua} "$monitors"
    fi
  '';
}
