{pkgs, ...}: {
  fonts.fontconfig = {
    enable = true;
    defaultFonts = {
      serif = ["Noto Serif"];
      sansSerif = ["Noto Sans"];
      monospace = ["Caskaydia Mono Nerd Font"];
    };
  };

  # Arabic script selection, ported from quattro's
  # default/fontconfig/conf.avail/50-omarchy.conf: prefer Naskh (standard
  # Arabic) over Nastaliq (Urdu style), keep Urdu on Nastaliq, and name Naskh as
  # a last-resort family so Chromium/Electron — which resolve missing glyphs one
  # character at a time, without lang on the pattern — don't fall through to a
  # raw charset scan that lands on Nastaliq or Kufi.
  xdg.configFile."fontconfig/conf.d/50-omarchy-arabic.conf".text = ''
    <?xml version="1.0"?>
    <!DOCTYPE fontconfig SYSTEM "urn:fontconfig:fonts.dtd">
    <fontconfig>
      <match target="pattern">
        <test name="lang" compare="contains">
          <string>ar</string>
        </test>
        <edit name="family" mode="prepend" binding="strong">
          <string>Noto Naskh Arabic</string>
        </edit>
      </match>

      <match target="pattern">
        <test name="lang" compare="contains">
          <string>ur</string>
        </test>
        <edit name="family" mode="append" binding="strong">
          <string>Noto Nastaliq Urdu</string>
        </edit>
      </match>

      <match target="pattern">
        <edit name="family" mode="append" binding="strong">
          <string>Noto Naskh Arabic</string>
        </edit>
      </match>
    </fontconfig>
  '';

  # CJK fallback, from the same upstream file: map each Chinese, Japanese and
  # Korean language tag to its Noto CJK variant, and give untagged Han the
  # Japanese forms. Only these two sections are taken. The rest of the file
  # makes Liberation Sans and JetBrainsMono the generic fonts, and this port
  # keeps the defaultFonts above. The build fails when upstream renames a
  # marker, so a changed file cannot slip through unseen.
  xdg.configFile."fontconfig/conf.d/50-omarchy-cjk.conf".source = pkgs.runCommand "50-omarchy-cjk.conf" {} ''
    ${pkgs.gawk}/bin/awk '
      NR <= 3 { head[NR] = $0 }
      /<!-- Normalize a private copy/ { cjk = 1 }
      cjk && /qual="any"/ { cjk = 0; cjk_done = 1; n-- }
      /<!-- Han with no language/ { han = 1 }
      han && /<family>system-ui<\/family>/ { han = 0; han_done = 1; n-- }
      cjk || han { body[++n] = $0 }
      END {
        if (!cjk_done || !han_done) { print "50-omarchy.conf: CJK markers are missing" > "/dev/stderr"; exit 1 }
        for (i = 1; i <= 3; i++) print head[i]
        for (i = 1; i <= n; i++) print body[i]
        print "</fontconfig>"
      }
    ' ${../../default/fontconfig/conf.avail/50-omarchy.conf} > $out
  '';

  # Don't autostart the print-queue applet (quattro config/autostart).
  xdg.configFile."autostart/print-applet.desktop".text = ''
    [Desktop Entry]
    Hidden=true
  '';

  # Install omarchy icon font as a nix package. The Noto CJK fonts are the
  # targets of the CJK rules above (upstream noto-fonts-cjk).
  home.packages = [
    pkgs.noto-fonts-cjk-sans
    pkgs.noto-fonts-cjk-serif
    (pkgs.stdenvNoCC.mkDerivation {
      name = "omarchy-font";
      src = ../../config;
      dontUnpack = true;
      installPhase = ''
        mkdir -p $out/share/fonts/truetype
        cp $src/omarchy.ttf $out/share/fonts/truetype/omarchy.ttf
      '';
    })
  ];
}
