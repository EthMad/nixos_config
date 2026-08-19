

 {pkgs, lib, llm-agents-pkgs, ... }:

 # List yo packages son!

 {
   environment.systemPackages = with pkgs; [
   neovim
   htop
   fastfetch


   firefox
   discord
   slack

   steam

   mesa
   mesa-demos

   protonup-qt

   prismlauncher
   jdk8
   jdk21

   git


   qbittorrent
   btop
   vlc
   

   libreoffice
   


   distrobox
   opencode
   #(llama-cpp.override { rocmSupport = true; })
   
   # Monitor GPU
   rocmPackages.rocm-smi
   amdgpu_top
   # VPN for remote AI hosting
   tailscale
   cockpit
   
   vscode
   kicad
   (callPackage ./stm32cubemx-latest.nix { })

   ethtool
   parted
   pciutils

   # Packages from llm-agents flake
   llm-agents-pkgs.pi
   llm-agents-pkgs.nanocoder
   llm-agents-pkgs.omp
   ];
   
   services.tailscale.enable = true;
   # Cockpit — only accessible over Tailscale (100.64.0.0/10)
   # Cockpit — only accessible over Tailscale (100.64.0.0/10)
   services.cockpit = {
     enable = true;
     port = 9090;
     openFirewall = false;  # we handle firewall manually via trustedInterfaces
     settings = {
       WebService = {
         AllowUnencrypted = lib.mkForce "false";
         Origins = lib.mkForce "https://100.111.140.18:9090 https://nixos.ts.net:9090";
         # Bind only to Tailscale interface IP — not 0.0.0.0
         ListenAddresses = "100.111.140.18:9090";
       };
     };
   };

   programs.steam = {
      enable = true;
      remotePlay.openFirewall = true; # Open ports in the firewall for Steam Remote Play
      dedicatedServer.openFirewall = true; # Open ports in the firewall for Source Dedicated Server
      localNetworkGameTransfers.openFirewall = true; # Open ports in the firewall for Steam Local Network Game Transfers
   };

}


