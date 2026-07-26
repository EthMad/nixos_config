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
    neowall    # GPU shader wallpaper engine (PS3 XMB wave) - see neowall service below
  ];

  # ============================================================================
  # PLASMA CONFIGURATION
  # ============================================================================
  # NOTE: neowall (see below) draws to its own Wayland layer-shell surface /
  # X11 root window, NOT through Plasma's wallpaper plugin system. This means
  # wallpaperSlideShow below and neowall are two independent rendering layers
  # that can both be "on" at once but will visually compete for the same
  # screen space. If neowall's PS3 wave shader is working the way you want,
  # consider disabling wallpaperSlideShow (or just letting it sit idle behind
  # neowall's surface) to avoid confusion about which one you're seeing.
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

  # ============================================================================
  # NEOWALL (PS3 XMB WAVE LIVE WALLPAPER)
  # ============================================================================
  # GPU shader wallpaper engine (https://github.com/1ay1/neowall), packaged
  # natively in nixpkgs. Renders unmodified Shadertoy GLSL directly via EGL,
  # pauses itself when a window covers the screen.
  #
  # Shader source is the "Ps3 XMB Wave" Shadertoy (fcf3Dn), a fullscreen-
  # optimized fork of int_45h's original (XdGfRR) intended for wallpaper use.
  xdg.configFile = {
    "neowall/shaders/ps3_wave.glsl".source = ./files/ps3_wave.glsl;
    "neowall/config.vibe".text = ''
      default {
        shader ps3_wave.glsl
        shader_speed 1.0
      }
    '';
  };

  # Autostart neowall with the graphical Plasma session. Restarts on crash.
  systemd.user.services.neowall = {
    Unit = {
      Description = "neowall GPU shader wallpaper (PS3 XMB wave)";
      After = [ "graphical-session.target" ];
      PartOf = [ "graphical-session.target" ];
    };
    Service = {
      Type = "forking";
      ExecStart = "${pkgs.neowall}/bin/neowall";
      ExecStop = "${pkgs.neowall}/bin/neowall kill";
      Restart = "on-failure";
      RestartSec = 2;
    };
    Install = {
      WantedBy = [ "graphical-session.target" ];
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
