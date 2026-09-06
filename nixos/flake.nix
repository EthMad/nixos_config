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

    mcp-nixos.url = "github:utensils/mcp-nixos";
    
    llama-cpp = {
       url = "github:ggml-org/llama.cpp";
       inputs.nixpkgs.follows = "nixpkgs";
    };

    llama-rdna2 = {
      # master: the RDNA2/V620 work (exp-gpu-sampling, gfx1030-optimizations,
      # perf/v620-*) has all been merged into master (2026-08); the old
      # exp-gpu-sampling branch is 800+ commits behind and stale.
      url = "github:edwinbrowwn/llama.cpp-rdna2/master";
      flake = false;
    };

  };

  outputs = { self, nixpkgs, ... }@inputs:
    let
      system = "x86_64-linux";
    in {
    # RDNA2 (gfx1030 / Radeon PRO V620) build of the llama.cpp-rdna2 fork.
    # Built from the fork's own .devops/nix/package.nix with ROCm enabled and
    # HIP kernels compiled for gfx1030 only — the package default would
    # target every GPU in nixpkgs' rocmPackages.clr.gpuTargets list.
    packages.${system}.llama-rdna2 =
      let
        pkgsRdna2 = import nixpkgs {
          inherit system;
          config = {
            rocmSupport = true;
            allowUnfree = true;
          };
        };
        llamaRdna2 = pkgsRdna2.callPackage "${inputs.llama-rdna2}/.devops/nix/package.nix" {
          llamaVersion = "0.0.0";
          rocmGpuTargets = "gfx1030";
          # Skip the bundled webui (npm build, ~2.4 GiB of deps) — the existing
          # Vulkan setup (nixpkgs llama-cpp-vulkan) also ships without it, and
          # llama-server works fine as a pure API server.
          useWebUi = false;
        };
      in
      # The fork defines `webui` as a field of the derivation attrset, so the
      # `derivation` builtin makes it an input drv even when useWebUi = false.
      # Replace it with a plain string to drop the whole webui build (npm
      # tree, nodejs, vite) from the dependency graph. postPatch only
      # references it when useWebUi is true, so this is safe.
      llamaRdna2.overrideAttrs (final: prev: { webui = ""; });
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
    nixosConfigurations."5820" = nixpkgs.lib.nixosSystem {
      inherit system;
      specialArgs = {
        inherit inputs;
        llm-agents-pkgs = inputs.llm-agents.packages.${system};
      };
      modules = [
        ./hosts/5820/configuration.nix
        inputs.home-manager.nixosModules.default
        {
          home-manager.sharedModules = [
            inputs.plasma-manager.homeModules.plasma-manager
          ];

          #home-manager.backupFileExtension = "backup";
        }
      ];
    };
  };
}
