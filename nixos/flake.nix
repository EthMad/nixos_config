{
  description = "Nixos config flake";

  inputs = {
    # Keep stable nixpkgs for most of the system
    nixpkgs.url = "github:nixos/nixpkgs/nixos-25.11";

    # Add unstable nixpkgs for packages that require it
    nixpkgs-unstable.url = "github:nixos/nixpkgs/nixos-unstable";

    home-manager = {
       url = "github:nix-community/home-manager/release-25.11";
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
      inputs.nixpkgs.follows = "nixpkgs-unstable";
    };
  };

  outputs = { self, nixpkgs, nixpkgs-unstable, ... }@inputs:
    let
      system = "x86_64-linux";

      # Create an overlay to make unstable packages available
      overlay-unstable = final: prev: {
        unstable = import nixpkgs-unstable {
          inherit system;
          config.allowUnfree = true;
        };
      };
    in {
    nixosConfigurations.nixos = nixpkgs.lib.nixosSystem {
      inherit system;
      specialArgs = {inherit inputs;};
      modules = [
        # Add the overlay so we can access pkgs.unstable
        ({ config, pkgs, ... }: {
          nixpkgs.overlays = [ overlay-unstable ];
        })

        ./configuration.nix
        inputs.home-manager.nixosModules.default
        {
          home-manager.sharedModules = [
            inputs.plasma-manager.homeManagerModules.plasma-manager
          ];
        }
      ];
    };
  };
}
