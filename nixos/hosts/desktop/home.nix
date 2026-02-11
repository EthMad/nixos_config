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
  # NOCTALIA SHELL CONFIGURATION
  # All configuration is done declaratively through Home Manager
  # ============================================================================
  programs.noctalia-shell = {
    enable = true;

    settings = {
      bar = {
        density = "default";
        position = "top";
        showCapsule = true;
        widgets = {
          left = [
            { id = "Launcher"; }
            { id = "Clock"; }
            { id = "ActiveWindow"; }
          ];
          center = [
            { id = "Workspace"; }
          ];
          right = [
            { id = "Tray"; }
            { id = "NotificationHistory"; }
            { id = "Battery"; }
            { id = "Volume"; }
            { id = "Brightness"; }
            { id = "ControlCenter"; }
          ];
        };
      };

      general = {
        avatarImage = "${config.home.homeDirectory}/.face";
        radiusRatio = 1.0;
      };

      location = {
        name = "Raleigh, North Carolina";
        useFahrenheit = true;
        use12hourFormat = true;
      };

      # Use the default Noctalia color scheme
      # You can change this to other schemes like "Monochrome", "Catppuccin", etc.
      colorSchemes.predefinedScheme = "Noctalia (default)";
    };
  };

  # ============================================================================
  # NIRI COMPOSITOR CONFIGURATION
  # Using direct KDL configuration file (not the niri-flake module)
  # This avoids build failures and uses the stable Niri from nixpkgs
  # ============================================================================
  xdg.configFile."niri/config.kdl".text = ''
    // Spawn Noctalia on startup
    spawn-at-startup "noctalia-shell"

    input {
        keyboard {
            xkb {
                layout "us"
            }
        }

        touchpad {
            tap
            natural-scroll
        }
    }
    output "DP-2"{
        mode "2560x1440@164.999"
    }
    output "HDMI-A-1"{
       position x=-1080 y=0
    }

    layout {
        gaps 2
        always-center-single-column
    }

    binds {
        // Noctalia shortcuts
        Mod+Space { spawn "noctalia-shell" "ipc" "call" "launcher" "toggle"; }
        Mod+Shift+L { spawn "noctalia-shell" "ipc" "call" "lockScreen" "lock"; }
        Mod+C { spawn "noctalia-shell" "ipc" "call" "controlCenter" "toggle"; }
        Mod+E { spawn "noctalia-shell" "ipc" "call" "sessionMenu" "toggle"; }
	Mod+D { spawn "noctalia-shell" "ipc" "call" "launcher" "toggle"; }

        // Audio controls
        XF86AudioLowerVolume { spawn "noctalia-shell" "ipc" "call" "volume" "decrease"; }
        XF86AudioRaiseVolume { spawn "noctalia-shell" "ipc" "call" "volume" "increase"; }
        XF86AudioMute { spawn "noctalia-shell" "ipc" "call" "volume" "muteOutput"; }
        XF86AudioMicMute { spawn "noctalia-shell" "ipc" "call" "volume" "muteInput"; }

        // Brightness controls
        XF86MonBrightnessDown { spawn "noctalia-shell" "ipc" "call" "brightness" "decrease"; }
        XF86MonBrightnessUp { spawn "noctalia-shell" "ipc" "call" "brightness" "increase"; }

        // Media controls
        XF86AudioPlay { spawn "noctalia-shell" "ipc" "call" "media" "playPause"; }
        XF86AudioNext { spawn "noctalia-shell" "ipc" "call" "media" "next"; }
        XF86AudioPrev { spawn "noctalia-shell" "ipc" "call" "media" "previous"; }

        // Window management
        Mod+Q { close-window; }
        Mod+Return { spawn "alacritty"; }

        // Window focus
        Mod+H { focus-column-left; }
        Mod+J { focus-window-down; }
        Mod+K { focus-window-up; }
        Mod+L { focus-column-right; }
        Mod+Left { focus-column-left; }
        Mod+Down { focus-window-down; }
        Mod+Up { focus-window-up; }
        Mod+Right { focus-column-right; }

        // Window movement
        Mod+Shift+H { move-column-left; }
        Mod+Shift+J { move-window-down; }
        Mod+Shift+K { move-window-up; }
        Mod+Ctrl+L { move-column-right; }
        Mod+Shift+Left { move-column-left; }
        Mod+Shift+Down { move-window-down; }
        Mod+Shift+Up { move-window-up; }
        Mod+Shift+Right { move-column-right; }

        // Workspace switching
        Mod+1 { focus-workspace 1; }
        Mod+2 { focus-workspace 2; }
        Mod+3 { focus-workspace 3; }
        Mod+4 { focus-workspace 4; }
        Mod+5 { focus-workspace 5; }
        Mod+6 { focus-workspace 6; }
        Mod+7 { focus-workspace 7; }
        Mod+8 { focus-workspace 8; }
        Mod+9 { focus-workspace 9; }

        // Move window to workspace
        Mod+Ctrl+1 { move-column-to-workspace 1; }
        Mod+Ctrl+2 { move-column-to-workspace 2; }
        Mod+Ctrl+3 { move-column-to-workspace 3; }
        Mod+Ctrl+4 { move-column-to-workspace 4; }
        Mod+Ctrl+5 { move-column-to-workspace 5; }
        Mod+Ctrl+6 { move-column-to-workspace 6; }
        Mod+Ctrl+7 { move-column-to-workspace 7; }
        Mod+Ctrl+8 { move-column-to-workspace 8; }
        Mod+Ctrl+9 { move-column-to-workspace 9; }

        // Fullscreen
        Mod+F { fullscreen-window; }

        // Quit Niri
        Mod+Shift+E { quit; }

	// Screenshot
	Mod+Shift+S { screenshot; }

	//Toggle Maximize
	Mod+M { maximize-window-to-edges; }

    }
  '';

  # ============================================================================
  # PLASMA CONFIGURATION (keeping your existing setup)
  # ============================================================================
  programs.plasma = {
    enable = true;
    workspace.wallpaper = "${config.home.homeDirectory}/Pictures/wallpaper.png";
  };

  # ============================================================================
  # FILE MANAGEMENT
  # ============================================================================
  home.file = {
    "Pictures/wallpaper.png".source = ./files/wallhaven-yqqywk_3840x2160.png;
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
