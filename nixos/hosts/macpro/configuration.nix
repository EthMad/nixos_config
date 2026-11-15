# Edit this configuration file to define what should be installed on
# your system.  Help is available in the configuration.nix(5) man page
# and in the NixOS manual (accessible by running 'nixos-help').

{ config, pkgs, inputs, ... }:

{
  imports =
    [ # Include the results of the hardware scan.
      ./hardware-configuration.nix
      ./apps.nix
      ../../modules/apps.nix
      #./llama-cpp-rocm.nix
      #./llama-cpp-rdna2.nix
    ];

  # Bootloader.
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  # Use latest kernel.
  # boot.kernelPackages = pkgs.linuxPackages_latest;

  # V620 power tuning: patch the kernel so amdgpu reports a 120 W minimum PPT
  # limit for the Radeon PRO V620 (its VBIOS locks the floor to 250 W, which
  # makes any lower cap rejected with EINVAL). With this, sysfs power1_cap
  # accepts values down to 120 W.
  # See: https://blivioniag.github.io/gfx1030-wiki/tuning/power.html
  # Note: first build compiles the kernel locally (one-time cost); the patch
  # is re-applied automatically on every kernel update.
#  boot.kernelPatches = [
#    {
#      name = "v620-powercap-min-120W";
#      patch = ./files/v620-powercap-min-120W.patch;
#    }
#  ];

  networking.hostName = "macpro"; # Define your hostname.
  # networking.wireless.enable = true;  # Enables wireless support via wpa_supplicant.

  # Configure network proxy if necessary
  # networking.proxy.default = "http://user:password@proxy:port/";
  # networking.proxy.noProxy = "127.0.0.1,localhost,internal.domain";

  # Enable networking
  networking.networkmanager.enable = true;
  networking.networkmanager.appendNameservers = [ "1.1.1.1" "8.8.8.8" ];
  hardware.firmware = [
    (pkgs.runCommand "macpro-broadcom-wifi-firmware" {} ''
      mkdir -p "$out/lib/firmware/brcm"
      cp -a ${./firmware/brcm}/. "$out/lib/firmware/brcm/"
    '')
  ];

  # Fix macpro build?
  hardware.apple-t2.kernelChannel = "stable";
  

  # Set your time zone.
  time.timeZone = "America/New_York";

  # Select internationalisation properties.
  i18n.defaultLocale = "en_US.UTF-8";

  i18n.extraLocaleSettings = {
    LC_ADDRESS = "en_US.UTF-8";
    LC_IDENTIFICATION = "en_US.UTF-8";
    LC_MEASUREMENT = "en_US.UTF-8";
    LC_MONETARY = "en_US.UTF-8";
    LC_NAME = "en_US.UTF-8";
    LC_NUMERIC = "en_US.UTF-8";
    LC_PAPER = "en_US.UTF-8";
    LC_TELEPHONE = "en_US.UTF-8";
    LC_TIME = "en_US.UTF-8";
  };

  # Enable the X11 windowing system.
  # You can disable this if you're only using the Wayland session.
  services.xserver.enable = true;

  # Enable the KDE Plasma Desktop Environment.
  services.displayManager.sddm.enable = true;
  services.desktopManager.plasma6.enable = true;

  # Configure keymap in X11
  services.xserver.xkb = {
    layout = "us";
    variant = "";
  };

  # Enable CUPS to print documents.
  services.printing.enable = true;

  # Enable sound with pipewire.
  services.pulseaudio.enable = false;
  security.rtkit.enable = true;
  services.pipewire = {
    enable = true;
    alsa.enable = true;
    alsa.support32Bit = true;
    pulse.enable = true;
    # If you want to use JACK applications, uncomment this
    #jack.enable = true;

    # use the example session manager (no others are packaged yet so this is enabled by default,
    # no need to redefine it in your config for now)
    #media-session.enable = true;
  };


  # Define a user account. Don't forget to set a password with 'passwd'.
  users.users.ethan = {
    isNormalUser = true;
    description = "Ethan Madren";
    extraGroups = [ "networkmanager" "wheel" ];
    packages = with pkgs; [
      kdePackages.kate
    #  thunderbird
    ];
  };

  home-manager = {
    #also pass inputs to home-manger modules
    extraSpecialArgs = { inherit inputs; };
    users = {
      "ethan" = import ./home.nix;
    };
  };

  # Allow unfree packages
  nixpkgs.config.allowUnfree = true;

  # List packages installed in system profile. To search, run:
  # $ nix search wget

  # Enable the OpenSSH daemon.
  # services.openssh.enable = true;
  services.openssh = {
    enable = true;
    ports = [ 22 ];
    settings = {
      PasswordAuthentication = false;
      PermitRootLogin = "no";
      MaxAuthTries = 3;
      AllowUsers = [ "ethan" ];
    };
  };


  # Open ports in the firewall.
  # networking.firewall.allowedTCPPorts = [ ... ];
  # networking.firewall.allowedUDPPorts = [ ... ];
  # Or disable the firewall altogether.
  networking.firewall = {
    enable = true;
    allowedTCPPorts = [ 22 2222 25566 8080 9090 ];  # Minecraft port, llama-server port, cockpit port
    # Optional: allowedUDPPorts = [ 25566 ]; # For LAN discovery
    trustedInterfaces = [ "tailscale0" ];  
  };

  # ============================================================================
  # ADDITIONAL STORAGE DRIVES
  # ============================================================================

  # This value determines the NixOS release from which the default
  # settings for stateful data, like file locations and database versions
  # on your system were taken. It's perfectly fine and recommended to leave
  # this value at the release version of the first install of this system.
  # Before changing this value read the documentation for this option
  # (e.g. man configuration.nix or on https://nixos.org/nixos/options.html).
  system.stateVersion = "25.11"; # Did you read the comment?

  nix.settings.experimental-features = [
    "nix-command"
    "flakes"
  ];

  # Enabling flatpaks for Sober a way to play roblox on linux
  services.flatpak.enable = true;


  # Enabling virtualization for distrobox
  virtualisation.containers.enable = true;
  
  virtualisation.podman = {
    enable = true;
    dockerCompat = true;
  };
  # Open WebUI - web frontend for the llama-server on port 8080
  #services.open-webui = {
  #  enable = true;
  #  host = "0.0.0.0";
  #  port = 3000;
  #  openFirewall = true;
  #};
  



  # Enabling support for OpenGL
  hardware.graphics = {
    enable = true;
    enable32Bit = true;  # needed for LWJGL natives
    extraPackages = with pkgs; [
      mesa
      rocmPackages.clr  # OpenCL, optional but useful
    ];
  };	


}
