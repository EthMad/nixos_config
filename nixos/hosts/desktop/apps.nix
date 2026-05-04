

 {pkgs, lib, llm-agents-pkgs, ... }:

 # List yo packages son!

 {
   environment.systemPackages = with pkgs; [
   neovim
   htop
   fastfetch

   firefox
   discord

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
   (llama-cpp.override { rocmSupport = true; })
   # Monitor GPU
   rocmPackages.rocm-smi
   amdgpu_top
   # VPN for remote AI hosting
   tailscale
   cockpit
   vscode

   # Packages from llm-agents flake
   llm-agents-pkgs.pi
   llm-agents-pkgs.nanocoder
   llm-agents-pkgs.omp
   ];
   
   services.tailscale.enable = true;

   services.cockpit = {
      enable = true;
      port = 9090;
      settings = {
         WebService = {
	 AllowUnencrypted = lib.mkForce "true";
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


