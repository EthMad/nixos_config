

 {pkgs, ... }:

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

   git

  ];

  programs.steam = {
   enable = true;
   remotePlay.openFirewall = true; # Open ports in the firewall for Steam Remote Play
   dedicatedServer.openFirewall = true; # Open ports in the firewall for Source Dedicated Server
   localNetworkGameTransfers.openFirewall = true; # Open ports in the firewall for Steam Local Network Game Transfers
  };

}


