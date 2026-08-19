{ pkgs, ... }:

{
  environment.systemPackages = with pkgs; [
    # Pull the official, cached nixpkgs binary
    llama-cpp-vulkan
    mcp-nixos
  ];
}
