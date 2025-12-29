{
  config,
  pkgs,
  ...
}: {
  # Hyprland Preview Share Picker configuration
  # Provides a visual screen share selector with window/output/region options

  xdg.configFile."hyprland-preview-share-picker/config.yaml".text = ''
    # Paths to stylesheets on the filesystem which should be applied to the application
    # Note: CSS theming is handled via base16 in the future
    stylesheets: []

    # Default page selected when the picker is opened
    default_page: windows

    window:
      # Height of the application window
      height: 500
      # Width of the application window
      width: 1000

    image:
      # Size to which the images should be internally resized to reduce the memory footprint
      resize_size: 500
      # Target size of the longer side of the image widget
      widget_size: 150

    classes:
      window: window
      image_card: card
      image_card_loading: card-loading
      image: image
      image_label: image-label
      notebook: notebook
      tab_label: tab-label
      notebook_page: page
      region_button: region-button
      restore_button: restore-button

    windows:
      # Minimum amount of image cards per row on the windows page
      min_per_row: 3
      # Maximum amount of image cards per row on the windows page
      max_per_row: 999
      # Number of clicks needed to select a window
      clicks: 1
      # Spacing in pixels between the window cards
      spacing: 12

    outputs:
      # Number of clicks needed to select an output
      clicks: 1
      # Spacing in pixels between the outputs in the layout
      spacing: 6
      # Show the label with the output name
      show_label: false
      # Size the output cards respectively to their scaling
      respect_output_scaling: true

    region:
      # Command to run for region selection
      # The output needs to be in the <output>@<x>,<y>,<w>,<h> format
      command: slurp -f '%o@%x,%y,%w,%h'

    # Hide the token restore checkbox and use the default value instead
    hide_token_restore: true
    # Enable debug logs by default
    debug: false
  '';
}
