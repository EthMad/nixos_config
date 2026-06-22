{ config, pkgs, inputs, ... }:

{
  # Home Manager needs a bit of information about you and the paths it should
  # manage.
  home.username = "ethan";
  home.homeDirectory = "/home/ethan";

  # This value determines the Home Manager release that your configuration is
  # compatible with. This helps avoid breakage when a new Home Manager release
  # introduces backwards incompatible changes.
  home.stateVersion = "25.11"; # Please read the comment before changing.

  # Import the Noctalia Home Manager module
  imports = [
    inputs.noctalia.homeModules.default
  ];

  # Allow unfree packages in home-manager
  nixpkgs.config.allowUnfree = true;

  # The home.packages option allows you to install Nix packages into your
  # environment.
  home.packages = with pkgs; [
    vesktop
    alacritty  # Terminal emulator for Niri
  ];

  # ============================================================================
  # PLASMA CONFIGURATION
  # ============================================================================
  programs.plasma = {
    enable = true;
    workspace = {
      wallpaperSlideShow = {
        path = "${config.home.homeDirectory}/Pictures/wallpapers";
        interval = 86400; # 86400 seconds = 24 hours (daily rotation)
      };
    };
  };

  # ============================================================================
  # FILE MANAGEMENT
  # ============================================================================
  home.file = {
    # Symlink ~/Pictures/wallpapers -> /etc/nixos/files/wallpapers
    # Using mkOutOfStoreSymlink so you can drop new wallpapers in freely
    # without needing to rebuild — just add files to /etc/nixos/files/wallpapers/
    "Pictures/wallpapers" = {
      source = config.lib.file.mkOutOfStoreSymlink "/etc/nixos/hosts/desktop/files/wallpapers";
    };
  };
  
  # Home Manager can also manage your environment variables through
  # 'home.sessionVariables'.
  home.sessionVariables = {
    # EDITOR = "emacs";
  };

  # Let Home Manager install and manage itself.
  programs.home-manager.enable = true;




  programs.firefox = {
    enable = true;

    profiles.default = {
      id = 0;
      name = "default";
      isDefault = true;

      # Your userChrome.css
      userChrome = ''
      /* Hide the horizontal tab bar */
      #TabsToolbar {
        visibility: collapse !important;
      }

      /* Hide the sidebar header */
      #sidebar-header {
        visibility: collapse !important;
      }

      /* Hide Firefox's new native sidebar panel (if using Firefox 133+) */
      #sidebar-main,
      #sidebar-launcher-splitter {
        display: none !important;
      }

      /* Optional: Hide the sidebar splitter for a cleaner look */
      #sidebar-box[sidebarcommand="_3c078156-979c-498b-8990-85f7987dd929_-sidebar-action"] + #sidebar-splitter {
        display: none !important;
      }

      /* Clean up sidebar styling */
      #sidebar-box {
        padding: 0 !important;
      }

      #sidebar-box #sidebar {
        box-shadow: none !important;
        border: none !important;
        outline: none !important;
        border-radius: 0 !important;
      }
      '';


      settings = {
        # Enable userChrome.css support
        "toolkit.legacyUserProfileCustomizations.stylesheets" = true;
        "sidebar.verticalTabs" = true;
        # Other settings...
      };
    };
  };
}
