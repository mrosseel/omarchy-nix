{pkgs, ...}: {
  # Evince PDF viewer - same as omarchy
  home.packages = [pkgs.evince];

  # Set evince as default for PDFs
  xdg.mimeApps = {
    enable = true;
    defaultApplications = {
      "application/pdf" = "org.gnome.Evince.desktop";
    };
  };
}
