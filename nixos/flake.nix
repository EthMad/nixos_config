{
  description = "Nixos config flake";

  inputs = {
    # Keep stable nixpkgs for most of the system
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";


    home-manager = {
       url = "github:nix-community/home-manager";
       inputs.nixpkgs.follows = "nixpkgs";
    };

    plasma-manager = {
       url = "github:nix-community/plasma-manager";
       inputs.nixpkgs.follows = "nixpkgs";
       inputs.home-manager.follows = "home-manager";
    };

    # Noctalia shell - uses unstable nixpkgs
    noctalia = {
      url = "github:noctalia-dev/noctalia-shell";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    llm-agents = {
      url = "github:numtide/llm-agents.nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };

  };

  outputs = { self, nixpkgs, ... }@inputs:
    let
      system = "x86_64-linux";
    in {
    nixosConfigurations.desktop = nixpkgs.lib.nixosSystem {
      inherit system;
      specialArgs = {
        inherit inputs;
	llm-agents-pkgs = inputs.llm-agents.packages.${system};
      };
      modules = [
        ./hosts/desktop/configuration.nix
        inputs.home-manager.nixosModules.default
        {
          home-manager.sharedModules = [
            inputs.plasma-manager.homeModules.plasma-manager
          ];

          #home-manager.backupFileExtension = "backup";
        }
      ];
    };
    nixosConfigurations.laptop = nixpkgs.lib.nixosSystem {
      inherit system;
      specialArgs = {
        inherit inputs;
      };
      modules = [
        ./hosts/laptop/configuration.nix
        inputs.home-manager.nixosModules.default
        {
          home-manager.sharedModules = [
            inputs.plasma-manager.homeModules.plasma-manager
          ];

          home-manager.backupFileExtension = "backup";
        }
      ];
    };
  };
}
