{
  description = "simple flake";
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";
    nix-darwin.url = "github:nix-darwin/nix-darwin/master";
    nix-darwin.inputs.nixpkgs.follows = "nixpkgs";
    home-manager.url = "github:nix-community/home-manager";
    home-manager.inputs.nixpkgs.follows = "nixpkgs";
    nxchad.url = "path:..";
    nxchad.inputs.nixpkgs.follows = "nixpkgs";
    nxchad.inputs.nixvim.follows = "nixvim";
    nixvim.url = "github:nix-community/nixvim";
    nixvim.inputs.nixpkgs.follows = "nixpkgs";
    systems.url = "github:nix-systems/default";
    search.url = "github:NuschtOS/search";
    search.inputs.nixpkgs.follows = "nixpkgs";
  };

  outputs = inputs @ { nixvim, nixpkgs, nix-darwin, nxchad, home-manager, ... }: let
    inherit (nixpkgs) lib;
    systems = import inputs.systems;
    eachSystem = lib.genAttrs systems;
  in {
    packages = eachSystem (system: {
      default = nxchad.packages.${system}.default;
      search = inputs.search.packages.${system}.mkSearch {
        title = "NxChad Options";
        urlPrefix = "https://github.com/fmway/NxChad/blob/master/";
        modules = [
          "${nxchad}/modules/nixvim/options/option.nix"
        ];
      };
    });

    nixosConfigurations = lib.listToAttrs (map (name: {
      inherit name;
      value = lib.nixosSystem {
        system = "${name}-linux";
        modules = [
          ({ modulesPath, ... }: {
            imports = [
              (modulesPath + "/installer/scan/not-detected.nix")
            ];

            boot.loader.grub = {
              mirroredBoots = [
                { devices = [ "nodev" ]; path = "/boot"; }
              ];
              device = "nodev";
            };
            # FAKE
            fileSystems."/" =
              { device = "/dev/sda1";
              fsType = "ext4";
            };
          })
          nixvim.nixosModules.nixvim
          nxchad.nixosModules.nixvim
          {
            programs.nixvim.enable = true;
          }
        ];
      };
    }) [ "x86_64" "aarch64" ]);

    darwinConfigurations = lib.listToAttrs (map (name: {
      inherit name;
      value = let
        system = "${name}-darwin";
      in nix-darwin.lib.darwinSystem {
        modules = [
          nixvim.nixDarwinModules.nixvim
          nxchad.nixDarwinModules.nixvim
          {
            nixpkgs.hostPlatform = system;
            programs.nixvim.enable = true;
            system.stateVersion = (with builtins;
              fromJSON (
                readFile "${nix-darwin}/release.json"
              )).release;
          }
        ];
      };
    }) [ "x86_64" "aarch64" ]);

    homeConfigurations = lib.listToAttrs (map (system: {
      name = system;
      value = let
        pkgs = nixpkgs.legacyPackages.${system};
      in home-manager.lib.homeManagerConfiguration {
        inherit pkgs;
        modules = [
          {
            nixpkgs.config.allowUnfree = true;
            home = {
              stateVersion = (with builtins;
                fromJSON (
                  readFile "${home-manager}/release.json"
                )).release;
              username = "test";
              homeDirectory = "/home/test";
            };
          }
          nixvim.homeManagerModules.nixvim
          nxchad.homeManagerModules.nixvim
          {
            programs.nixvim.enable = true;
          }
        ];
      };
    }) systems);
  };
}
